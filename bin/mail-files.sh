#!/tmp/wahoo

# script to email files as attachments.
# ------------------------------------

# Additional documentation for this script, including a brief introdcution 
# to MIME can be found at:  http://home.clara.net/dwotton/unix/mail_files.htm

# Written: Dave Wotton, July 1998, (Cambridge UK)
#          This script comes with no warranty or support. You are
#          free to modify it as you wish, but please retain an
#          acknowledgement of my original authorship.

# Amended: Dave Wotton, 6/3/99
#          -t flag now optional. subject also optional
#
# Amended: Dave Wotton, 3/8/00
#          added -b and -u  options. By default a file-list which is not
#          preceded by a -n, -b, or -u flag is now NOT encoded (the previous
#          default was to base64 encode it.).
#
# Amended: Dave Wotton, 10/10/00
#          added a -c (cc:) option.
#          Added a tty -s test to prevent the prompt to enter the text body
#          being displayed when not connected to a tty. (The text body is
#          still required though. /dev/null will suffice.)
#
# Amended: Dave Wotton, 24/2/01
#          Now uses perl to perform the base64 encoding, as it comes as
#          standard on most modern Unixes. (You need the perl MIME package
#          though, which I believe is standard. )

# Amended: Dave Wotton, 22/09/01
#          Now creates a "To:" header and uses the sendmail -t flag to
#          duplicate this as the envelope recipients, rather than using the
#          user supplied list of addresses simply as envelope recipients.
#          This confused some mail clients, specifically Lotus Notes.

# Amended: Dave Wotton, 30/09/01
#          Now initialises the main variables, so that previously set
#          environment variable values (eg. $CC) aren't used instead.
#          Enable multiple occurrences of the -t and -c flags. Thanks to
#          Jason Judge for these suggestions.


# Usage:   mail_files [-t] mailid [ -c mailid ] [ -s subject ] [ -f mailid ] 
#          [-n file_list] [-u file_list] [-b file_list] file_list
#
#    -f      : The mailid of the sender ( defaults to your userid )
#              Only userids that have been defined as "trusted" in the sendmail
#              config file can make use of the -f option. For non-trusted users
#              any value specified by this parameter will be ignored by 
#              sendmail.
#    -t      : The mailid of the recipient. Mandatory, no default
#              multiple mailids can be specified, separated by commas.
#    -c      : The mailid of any carbon-copy recipients. Optional.
#              multiple mailids can be specified, separated by commas.
#    -s      : The subject string. Optional, default = "Not specified".
#              Enclose in quotes.
#    -n      : no-encode: indicates a list of files which are NOT to be base64
#              or uuencode encoded. Multiple files may be enclosed in double
#              quotes. Usual wildcard notation can be used. This option is
#              for completeness and can be omitted because the default action 
#              is not to encode the file-list.
#    -b      : base64 encoding: indicates a list of files which are to be 
#              base64 encoded. Multiple files may be enclosed in double quotes.
#              Usual wildcard notation can be used.
#    -u      : uuencode encoding: indicates a list of files which are to be 
#              uuencode encoded. Multiple files may be enclosed in double 
#              quotes. Usual wildcard notation can be used.
#  file_list : The list of files to send as attachments with no-encoding
#              (same as -n option, but the file list does not need to be
#              enclosed in quotes if more than one file specified). 
#              Usual wildcard notation can be used.

# The program will also prompt for text to be supplied on standard input
# as the main text of the message.

# eg.
#      1) mail_files Dave.Wotton -b file9.gif t*.htm < /dev/null
#
#         email file9.gif as a base64 encoded attachment and the t*.htm
#         files unencoded.
#
#      2) mail_files Dave.Wotton -s "my test" -b "file1.gif file2.gif" \
#                    < /dev/null
#
#         email file1.gif and file2.gif as base64 encoded attachments.

# The script makes use of perl's MIME package to perform the base-64 
# encoding/decoding. 

# Note that files destined for Windows environments should have a name of
# the form aaaa.bbb where aaaa is up to 8 characters long, and bbb is a
# 3 character sufix. The suffix determines which program is used to
# display/process the data at the remote end.

# Simple text files can be emailed unencoded. Binary files, or text files
# with long lines ( ie > 1000 chars ) should use the  base64 or uuencode 
# encoding procedures. Base64 is preferred because it is more universally
# supported. In particular, most PC mail-clients can automatically decode
# base64 encoded attachments. Note that simple text files with short lines 
# which are destined for PC environments should not be base64 encoded.
# This is because PCs use a different line-break character to Unix.
# If the text is base64 encoded, the line-breaks are not converted
# automatically and so the data arrives at the remote end without
# line-breaks.

# set up a 'usage' routine
# ------------------------

usage()
{
  [ "$1" ] && ( echo $* ; echo "" )

  cat <<!
  Usage:   mail_files [-t] mailid [ -c mailid ] [ -s subject ] [ -f mailid ] 
           [-n file_list] [-u file_list] [-b file_list] file_list
!
  exit 4
}

# Initialise main variables ...
# -------------------------

FROM=$LOGNAME
SUBJ=${SUBJ:-"Not specified"}

TO="" ; CC="" ; SUBJ="" ; NOENC="" ; BASE64="" ; UUE=""

# First parse the command line options. Using getopts means the parameters
# can be supplied in any order. But first we handle the first parameter,
# which may be a recipient, without a -t flag...

case "$1" in
   -* ) : ;;                   # ignore it, let getopts handle flags
    * ) TO=$1 ; shift ;;
esac

while getopts f:s:t:c:n:b:u: OPT
do
     case $OPT in
         "f" ) FROM=$OPTARG ;;
         "t" ) TO="$TO,$OPTARG" ;;
         "c" ) CC="$CC,$OPTARG" ;;
         "s" ) SUBJ=$OPTARG ;;
         "n" ) NOENC="$NOENC $OPTARG" ;;
         "b" ) BASE64="$BASE64 $OPTARG" ;;
         "u" ) UUE="$UUE $OPTARG" ;;
          *  ) usage ;;
     esac
done

shift `expr $OPTIND - 1`

if [ "$TO" = "" ]
then
    usage "An addressee must be specified"
fi

# All remaining parameters are files not requiring encoding ...
# ---------------------------------------------------------

# Build up $FILES as the list of non-encoded files. Use sed to remove
# any leading space from the variable.

FILES=`echo $NOENC $*|sed 's/^ //'`

if [ "$BASE64" = "" -a "$FILES" = "" -a "$UUE" = "" ]
then
    usage "At least one file must be specified"
fi

# Remove leading commas from TO, CC  ...
# ---------------------------------

TO=`echo $TO | sed 's/^,//'`
CC=`echo $CC | sed 's/^,//'`

# Validate that the files exist ...
# -----------------------------

for F in $FILES $BASE64 $UUE
do
   if [ ! -r $F ]
   then
      echo "Error: File $F does not exist / is not readable."
      echo "Exiting. ( Mail not sent )."
      exit
   fi
done

tty -s && echo "Enter text of main message ( finish with CTRL-D ) ..."

# Now do the work ...
# ---------------

# The generated mail message is output onto standard out, which is then
# piped in to sendmail.

(
cat <<!
From: $FROM
Subject: $SUBJ
To: $TO
!

[ "$CC" ] && echo "Cc: $CC"

cat <<!
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="DMW.Boundary.605592468"

This is a Mime message, which your mail program may not understand. Parts
of the message will appear as text. If the remainder appears as random
characters in the message body, instead of as attachments, then you'll
have to extract these parts and decode them manually.

--DMW.Boundary.605592468
Content-Type: text/plain; name="message.txt"; charset=US-ASCII
Content-Disposition: inline; filename="message.txt"
Content-Transfer-Encoding: 7bit

!

# Read the standard input as the main text of the message ...
# -------------------------------------------------------

cat - 

# Now process the non-encrypted attachments ...
# -----------------------------------------

if [ "$FILES" ]
then
    for F in $FILES
    do

       BASE=`basename $F`

       echo --DMW.Boundary.605592468
       echo Content-Type: application/octet-stream\; name=\"$BASE\"
       echo Content-Disposition: attachment\; filename=\"$BASE\"
       echo Content-Transfer-Encoding: 7bit
       echo

       cat $F

    done
fi

# Now process the base64 encrypted attachments ...
# --------------------------------------------

if [ "$BASE64" ]
then
    for F in $BASE64
    do

       BASE=`basename $F`

       echo --DMW.Boundary.605592468
       echo Content-Type: application/octet-stream\; name=\"$BASE\"
       echo Content-Disposition: attachment\; filename=\"$BASE\"
       echo Content-Transfer-Encoding: base64
       echo

       perl -e '
       use MIME::Base64 qw(encode_base64);
       local($/) = undef;
       print encode_base64(<STDIN>);' < $F

    done
fi

# Now process the uuencode encrypted attachments ...
# ----------------------------------------------

# Sorry, this bit is untested - I haven't got a mail-client which can
# handle uuencoded MIME messages automatically, so can't test if the
# 'Content-Transfer-Encoding: uuencode' line is correct and whether I
# need the uuencode "begin" and "end" lines.

if [ "$UUE" ]
then
    for F in $UUE
    do

       BASE=`basename $F`

       echo --DMW.Boundary.605592468
       echo Content-Type: application/octet-stream\; name=\"$BASE\"
       echo Content-Disposition: attachment\; filename=\"$BASE\"
       echo Content-Transfer-Encoding: uuencode
       echo

       uuencode < $F xxx 

    done
fi

# append the final boundary line ...

echo --DMW.Boundary.605592468--

) | /usr/lib/sendmail -t


