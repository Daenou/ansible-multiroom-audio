#!/bin/bash
#
# modes of operation
#
# -s : autosave    if needed or forced (-f)
# -r : autorestore if needed or forced (-f)
# -c : cleanup     if too many copies

MPDHOST=localhost
MPC="mpc -h $MPDHOST"
LOGGER="/usr/bin/logger -t $0"
MD5SUM=md5sum

MAXAUTOSAVE=20
PLAYLISTNAMEBASE=zz_autolist_

if [[ -r /etc/default/playlistbot ]]
then 
  . /etc/default/playlistbot
fi

usage () {

local errmsg=$1

echo ""
echo usage:
echo "$0 [-s|-r] [-c] [-f] [-d]"
echo ""
echo "-s save play list if different to last saved"
echo "-r restore latest autosaved playlist to current"
echo ""
echo "-d remove duplicates in current playlist"
echo "-c cleanup autosaved playlists (keeping $MAXAUTOSAVE copies)"
echo "-f force"
echo "   for save: save new list even if identical to previous"
echo "   for restore: do restore even if current not empty"
echo ""
if [[ ! -z "$errmsg" ]]
then
  echo "ERR $errmsg"
  echo ""
fi
exit 1
}

log () {
local msg="$1"

$LOGGER "$msg"
}

error () {
local msg="$1"

log "$msg"
usage "$msg"
}

if [[ ! -x `which $MD5SUM` ]] 
then 
  error "Need $MD5SUM installed"
fi 

DUPLICATES=no; SAVE=no; RESTORE=no; CLEANUP=no; FORCE=no

while getopts srcfd option
do
  case $option in 
    d) DUPLICATES=yes ;;
    s) SAVE=yes ;;
    r) RESTORE=yes ;;
    c) CLEANUP=yes ;;
    f) FORCE=yes ;;
  esac
done

if [[ "$SAVE" == "$RESTORE" ]]
then
  if [[ "$SAVE" == "yes" ]]
  then
    error "cannot save and restore at the same time"
  elif [[ "$CLEANUP" == "no" && "$DUPLICATES" == "no" ]]
  then
    error "No action selected SAVE ($SAVE) RESTORE ($RESTORE) CLEANUP ($CLEANUP) DUPLICATES ($DUPLICATES)"
  elif [[ "$FORCE" == "yes" ]]
  then
    error "FORCE does not make sense without SAVE or RESTORE, SAVE ($SAVE) RESTORE ($RESTORE) FORCE ($FORCE)"
  fi
fi

# only valid option combinations left

my_md5sum () {
  local SUM

  SUM=$( cat | $MD5SUM ) 
  set -- $SUM
  echo $1

}

# taken from: 
# 
# cat << EOF | my_md5sum
# EOF
# 
EMPTYSUM=d41d8cd98f00b204e9800998ecf8427e
# can also done like this: PLAYLIST=""

# Check mpd connectivity
if $MPC > /dev/null 
then
  log "connection to $MPC working"
else
  error "connection to $MPC not working"
fi

if [[ "$DUPLICATES" == "yes" ]]
then
  log "removing duplicates (if any)"

  PLAYLISTFILE=$( mktemp /tmp/playlist_XXXXXX )
  DELETEFILE=$( mktemp /tmp/deletelist_XXXXXX )
  
  $MPC playlist -f '%position% %file%' > $PLAYLISTFILE
  
  LASTLINE=""
  cat $PLAYLISTFILE | sort -k 2 | uniq -f1 -D | while read number filename
  do
    if [[ "$LASTLINE" == "$filename" ]]
      then 
        log "prepare deletion of $number $filename"
        echo $number >> $DELETEFILE
      else
        LASTLINE="$filename"
        log "keep $number $filename"
    fi
  done
  
  cat $DELETEFILE | sort -n -r | while read number
  do
    log "deleting $number"
    $MPC del $number
  done
  
  rm $PLAYLISTFILE
  rm $DELETEFILE
fi

# get current playlist
PLAYLIST=$( $MPC -f %file% playlist ) 
PLAYSUM=$( echo -n "$PLAYLIST" | my_md5sum )
log "found PLAYLIST $( echo "$PLAYLIST" | wc -l ) $PLAYSUM"

if [[ "$SAVE" == "yes" ]]
then
  if [[ "$PLAYSUM" == "$EMPTYSUM" ]]
  then
    log "SAVE: Not saving empty playlist"
  else
    # now get list of all saved playlists 
    LATESTSAVEDNAME=$( $MPC lsplaylists | egrep "^$PLAYLISTNAMEBASE" | sort | tail -1 ) 
    if [[ -z "$LATESTSAVEDNAME" ]]
    then
      LATESTSUM=none
    else
      LATESTPLAYLIST=$( $MPC -f %file% playlist $LATESTSAVEDNAME ) 
      LATESTSUM=$( echo -n "$LATESTPLAYLIST" | my_md5sum ) 
      log "found LATESTSAVEDNAME $LATESTSAVEDNAME LATESTPLAYLIST $( echo "$LATESTPLAYLIST" | wc -l ) $LATESTSUM"
    fi
    if [[ ( "$FORCE" == "yes" ) || ( "$PLAYSUM" != "$LATESTSUM" ) ]]
    then
      NEWPLAYNAME=${PLAYLISTNAMEBASE}$( date +%Y%m%d-%H%M%S)
      log "creating new playlist $NEWPLAYNAME - FORCE $FORCE PLAYSUM $PLAYSUM LATESTSUM $LATESTSUM"
      $MPC save $NEWPLAYNAME
    else
      log "not creating new playlist - FORCE $FORCE PLAYSUM $PLAYSUM LATESTSUM $LATESTSUM"
    fi
  fi
fi

if [[ "$RESTORE" == "yes" ]]
then
  if [[ ( "$FORCE" == "no" ) && "$PLAYSUM" != "$EMPTYSUM" ]]
  then
    log "RESTORE: Not restoring when current playlist is not empty and not forcing"
  else
    LATESTSAVEDNAME=$( $MPC lsplaylists | egrep "^$PLAYLISTNAMEBASE" | sort | tail -1 ) 
    if [[ -z "$LATESTSAVEDNAME" ]]
    then
      log "RESTORE: no matching playlist found for restore"
    else
      log "RESTORE: reload $LATESTSAVEDNAME"
      $MPC load $LATESTSAVEDNAME 
    fi
  fi
fi

if [[ "$CLEANUP" == "yes" ]]
then
  $MPC lsplaylists | egrep "^$PLAYLISTNAMEBASE" | sort | head -n -${MAXAUTOSAVE} | while read OLDPLAYLIST
  do
    log "CLEANUP $OLDPLAYLIST"
    $MPC rm $OLDPLAYLIST
  done
  log "No more than ${MAXAUTOSAVE} autoplaylists left:"
  $MPC lsplaylists | egrep "^$PLAYLISTNAMEBASE" | sort | while read name
  do
    log "PLAYLISTNAME $name"
  done
fi


