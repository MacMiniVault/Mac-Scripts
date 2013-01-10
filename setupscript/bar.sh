#! /bin/sh

# bar
# 'cat' with ASCII progress bar
# (c) Henrik Theiling
BAR_VERSION=1.4

# Synopsis:
#   'bar' works just like 'cat', but shows a progress bar in ASCII art on stderr.
#   The script's main function is meant to be usable in any Bourne shell to be
#   suitable for install scripts without the need for any additional tool.
#
# Shell Script Usage: bar [options] [files]
# Options:
#     -h        displays help
#     ...
#
# Examples:
#   Normal pipe:
#
#     : bar mypack.tar.bz2 | tar xjpf -
#
#   Individual pipe for each file:
#
#     : bar -c 'tar xjpf -' mypack1.tar.bz2 mypack2.tar.bz2
#
#   Individual pipe, using ${bar_file} variable:
#
#     : bar -c 'echo ${bar_file}: ; gzip -dc | tar tvf -' \
#     :     -e .tar.gz \
#     :     file1 file2 file3 file4 file5 \
#     :         > package-list.txt

#####################################################
# Programs and shell commands:
#
# Required (otherwise this fails):
#
#    if, then, else, fi, expr, test, cat, eval, exec
#    shell functions
#
#    test:
#        a = b
#        a -lt b
#        a -gt b
#        a -le b
#        -f a
#        -n a
#        -z a
#
#    expr:
#        a + b
#        a - b
#        a '*' b
#        a / b
#        a : b
#
# Optional (otherwise this does not show the bar):
#
#    grep, dd, echo, ls, sed, cut
#
#    ls:
#        must output the file size at fifth position.
#
# The command line interface also uses:
#
#    awk
#

####>-SCHNIPP-<########################################################
bar_cat()
{
   # Use this shell function in your own install scripts.

   #####################################################
   # Options:

   # Width of the bar (in ten characters).  The default is 76 characters.
   test -z "${BAR_WIDTH}" && test -n "${COLUMNS}" && BAR_WIDTH=${COLUMNS}

   # Check syntax:
   ( expr "${BAR_WIDTH}" + 0 >/dev/null 2>&1 ) || BAR_WIDTH=0
   BAR_WIDTH=`expr ${BAR_WIDTH} + 0` || BAR_WIDTH=0
   test "x${BAR_WIDTH}" = x0 && BAR_WIDTH=76

   # Maximal block size to use for dd.
   test -n "${BAR_BS}" || BAR_BS=1048567

   # BEGIN PERC
   # Whether to show a percentage.
   test -n "${BAR_PERC}" || BAR_PERC=1
   # END PERC

   # BEGIN ETA
   # Whether to show estimated time of arrival (ETA).
   test -n "${BAR_ETA}" || BAR_ETA=1
   # END ETA

   # Width of the trace display:
   # BEGIN TRACE
   test -n "${BAR_TRACE_WIDTH}" || BAR_TRACE_WIDTH=10
   # END TRACE

   # The command to execute for every given file.  Each file
   # is piped into this command individually.  By default, the
   # files are simply dumped to stdout.
   test -n "${BAR_CMD}" || BAR_CMD=cat

   # The characters to be used in the bar
   test -n "${BAR_L}"  || BAR_L='['
   test -n "${BAR_R}"  || BAR_R=']'
   test -n "${BAR_C0}" || BAR_C0='.'
   test -n "${BAR_C1}" || BAR_C1='='

   # Additional extension to add to each file:
   #BAR_EXT=${BAR_EXT-}

   # Whether to clear bar after termination.  Otherwise keep the full bar.
   #BAR_CLEAR=${BAR_CLEAR-0}

   # Unless switched off by user, use the bar by default:
   test -n "${BAR_OK}" || BAR_OK=1

   #####################################################
   BAR_WIDTH=`expr ${BAR_WIDTH} - 3`

   bar_trace=''
   # BEGIN TRACE
   if test "x${BAR_TRACE}" = x1
   then
       BAR_WIDTH=`expr ${BAR_WIDTH} - ${BAR_TRACE_WIDTH}`
       bar_lauf=${BAR_TRACE_WIDTH}
       bar_t_space=''
       bar_t_dot=''
       while test "${bar_lauf}" -gt 1
       do
           bar_t_space="${bar_t_space} "
           bar_t_dot="${bar_t_dot}."
           bar_lauf=`expr ${bar_lauf} - 1`
       done
       bar_trace="${bar_t_space} "
   fi
   # END TRACE

   bar_eta=''
   BAR_GET_TIME='echo'
   # BEGIN ETA
   ( expr 1 + ${SECONDS} >/dev/null 2>&1 ) || BAR_ETA=0
   if test "x${BAR_ETA}" = x1
   then
       BAR_GET_TIME='( echo ${SECONDS} )'
       BAR_WIDTH=`expr ${BAR_WIDTH} - 6`
       bar_eta='--:-- '
   fi
   # END ETA

   bar_perc=''
   # BEGIN PERC
   if test "x${BAR_PERC}" = x1
   then
       BAR_WIDTH=`expr ${BAR_WIDTH} - 5`
       bar_perc='  0% '
   fi
   # END PERC

   BAR_GET_SIZE='( ls -l "${BAR_DIR}${bar_file}${BAR_EXT}" | sed "s@  *@ @g" | cut -d " " -f 5 ) 2>/dev/null'
       # portable?

   # check features:
   ( ( echo a                   ) >/dev/null 2>&1 ) || BAR_OK=0
   ( ( echo a | dd bs=2 count=2 ) >/dev/null 2>&1 ) || BAR_OK=0
   ( ( echo a | grep a          ) >/dev/null 2>&1 ) || BAR_OK=0
   ( ( echo a | sed 's@  *@ @g' ) >/dev/null 2>&1 ) || BAR_OK=0
   ( ( echo a | cut -d ' ' -f 1 ) >/dev/null 2>&1 ) || BAR_OK=0

   # check ranges:
   test "${BAR_WIDTH}" -ge 4 || BAR_OK=0

   BAR_ECHO='echo'
   BAR_E_C1=''
   BAR_E_C2=''
   BAR_E_NL='echo'

   # Does echo accept -n without signalling an error?
   if echo -n abc >/dev/null 2>&1
   then
       BAR_E_C1='-n'
   fi

   # Check how to print a line without newline:
   if ( ( ${BAR_ECHO} "${BAR_E_C1}" abc ; echo 1,2,3 ) | grep n ) >/dev/null 2>&1
   then
       # Try echo \c:
       if ( ( ${BAR_ECHO} 'xyz\c' ; echo 1,2,3 ) | grep c ) >/dev/null 2>&1
       then
           # Try printf:
           if ( ( printf 'ab%s' c ; echo 1,2,3 ) | grep abc ) >/dev/null 2>&1
           then
              BAR_ECHO='printf'
              BAR_E_C1='%s'
           else
              BAR_ECHO=':'
              BAR_E_C1=''
              BAR_E_NL=':'
              BAR_OK=0
           fi
       else
          BAR_E_C1=''
          BAR_E_C2='\c'
       fi
   fi

   # prepare initial bar:
   bar_shown=0
   if test "${BAR_OK}" = 1
   then
       bar_lauf=0
       bar_graph=''
       while test `expr ${bar_lauf} + 5` -le "${BAR_WIDTH}"
       do
           bar_graph="${bar_graph}${BAR_C0}${BAR_C0}${BAR_C0}${BAR_C0}${BAR_C0}"
           bar_lauf=`expr ${bar_lauf} + 5`
       done
       while test "${bar_lauf}" -lt "${BAR_WIDTH}"
       do
           bar_graph="${bar_graph}${BAR_C0}"
           bar_lauf=`expr ${bar_lauf} + 1`
       done
       ${BAR_ECHO} "${BAR_E_C1}" "
${bar_trace}${bar_eta}${bar_perc}${BAR_L}${bar_graph}${BAR_R}
${BAR_E_C2}" 1>&2
       bar_shown=1
   fi

   # for shifting large numbers so that expr can handle them:
   # Assume we can compute up to 2147483647, thus 9 arbitrary digits.
   # We must be able to do + of two numbers of 9 digits length.  Ok.
   # BEGIN LARGE
   ( ( test 1999999998 = `expr 999999999 + 999999999` ) >/dev/null 2>&1 ) || BAR_OK=0
   bar_large_num="........."
   bar_div=""
   # END LARGE
   bar_numsuff=""

   # find size:
   bar_size=0
   if test -n "${BAR_SIZE}"
   then
       bar_size=${BAR_SIZE}
       # BEGIN LARGE
       while expr "${bar_size}" : "${bar_large_num}" >/dev/null 2>&1
       do
           bar_div="${bar_div}."
           bar_numsuff="${bar_numsuff}0"
           bar_size=`expr "${bar_size}" : '\(.*\).$'`
       done
       # END LARGE
       BAR_GET_SIZE="echo '${BAR_SIZE}'"
   else
       for bar_file
       do
           bar_size1=0
           if test -f "${BAR_DIR}${bar_file}${BAR_EXT}"
           then
               bar_size1=`eval "${BAR_GET_SIZE}"`

               # BEGIN LARGE
               # divide and upround by pattern matching:
               if test -n "${bar_div}"
               then
                   bar_size1=`expr "${bar_size1}" : '\(.*\)'${bar_div}'$'` || bar_size1=0
               fi

               # adjust if still too large:
               while expr "${bar_size1}" : "${bar_large_num}" >/dev/null 2>&1
               do
                   bar_div="${bar_div}."
                   bar_numsuff="${bar_numsuff}0"
                   bar_size1=`expr "${bar_size1}" : '\(.*\).$'`
                   bar_size=`expr "${bar_size}" : '\(.*\).$'` || bar_size=0
               done

               # upround if necessary:
               if test -n "${bar_div}"
               then
                   bar_size1=`expr "${bar_size1}" + 1`
               fi
               # END LARGE

               # add to total size:
               bar_size=`expr ${bar_size} + ${bar_size1}`

               # BEGIN LARGE
               # adjust if still too large:
               while expr "${bar_size}" : "${bar_large_num}" >/dev/null 2>&1
               do
                   bar_div="${bar_div}."
                   bar_numsuff="${bar_numsuff}0"
                   bar_size=`expr "${bar_size}" : '\(.*\).$'`
               done
               # END LARGE
           else
               BAR_OK=0
           fi
       done
   fi

   bar_quad=`expr ${BAR_WIDTH} '*' ${BAR_WIDTH}`
   test "${bar_size}" -gt "${bar_quad}" || BAR_OK=0

   if test "${BAR_OK}" = 0
   then
       # For some reason, we cannot display the bar.  Thus plain operation:
       for bar_file
       do
           if test "${bar_file}" = "/dev/stdin"
           then
               eval "${BAR_CMD}"
           else
               eval "${BAR_CMD}" < "${BAR_DIR}${bar_file}${BAR_EXT}"
           fi
       done
   else
       # Compute wanted bytes per step:
       bar_want_bps=`expr ${bar_size} + ${BAR_WIDTH}`
       bar_want_bps=`expr ${bar_want_bps} - 1`
       bar_want_bps=`expr ${bar_want_bps} / ${BAR_WIDTH}`

       # Compute block count per step to keep within maximum block size:
       bar_count=1
       if test "${bar_want_bps}" -gt "${BAR_BS}"
       then
           bar_count=`expr ${bar_want_bps} + ${BAR_BS}`
           bar_count=`expr ${bar_count} - 1`
           bar_count=`expr ${bar_count} / ${BAR_BS}`
       fi

       # Compute block size for given count:
       bar_wc=`expr ${BAR_WIDTH} '*' ${bar_count}`

       bar_bs=`expr ${bar_size} + ${bar_wc}`
       bar_bs=`expr ${bar_bs} - 1`
       bar_bs=`expr ${bar_bs} / ${bar_wc}`

       # Compute bs * count, the bytes per step:
       bar_bps=`expr ${bar_bs} '*' ${bar_count}`

       # Compute bytes per hundredth:
       bar_bph=`expr ${bar_size} + 99`
       bar_bph=`expr ${bar_bph} / 100`


       # Run loop:
       bar_pos=0
       bar_graph="${BAR_L}"
       bar_cur_char=0
       bar_t0=`eval "${BAR_GET_TIME}" 2>/dev/null` || bar_t0=0
       for bar_file
       do
           # BEGIN TRACE
           if test "x${BAR_TRACE}" = x1
           then
               bar_trace=`expr "${bar_file}" : '.*/\([^/][^/]*\)$'` || bar_trace="${bar_file}"
               bar_trace=`expr "${bar_trace}${bar_t_space}" : '\('${bar_t_dot}'\)'`
               bar_trace="${bar_trace} "
           fi
           # END TRACE
           # Initial character position in bar for file:
           bar_char=`expr ${bar_pos} / ${bar_want_bps}` || bar_char=0
           while test "${bar_char}" -gt `expr ${bar_cur_char} + 4`
           do
               bar_graph="${bar_graph}${BAR_C1}${BAR_C1}${BAR_C1}${BAR_C1}${BAR_C1}"
               bar_cur_char=`expr ${bar_cur_char} + 5`
           done
           while test "${bar_char}" -gt "${bar_cur_char}"
           do
               bar_graph="${bar_graph}${BAR_C1}"
               bar_cur_char=`expr ${bar_cur_char} + 1`
           done

           # Get file size.  This must work now (we checked with test -f before).
           bar_size1=`eval "${BAR_GET_SIZE}" 2>/dev/null` || bar_size1=0

           # BEGIN LARGE
           # Divide and upround by pattern matching:
           if test -n "${bar_div}"
           then
               bar_size1=`expr "${bar_size1}" : '\(.*\)'${bar_div}'$'` || bar_size1=0
               bar_size1=`expr "${bar_size1}" + 1`
           fi
           # END LARGE

           # loop:
           bar_total=0
           (
               exec 6>&1
               exec 5<"${BAR_DIR}${bar_file}${BAR_EXT}"
               while test "${bar_total}" -lt "${bar_size1}"
               do
                   dd bs="${bar_bs}" count="${bar_count}${bar_numsuff}" <&5 >&6 2>/dev/null
                   bar_total=`expr ${bar_total} + ${bar_bps}`
                   if test "${bar_total}" -gt "${bar_size1}"
                   then
                       bar_total="${bar_size1}"
                   fi
                   bar_pos1=`expr ${bar_pos} + ${bar_total}`
                   bar_proz=`expr ${bar_pos1} / ${bar_bph}` || bar_proz=0
                   # BEGIN PERC
                   if test "x${BAR_PERC}" = x1
                   then
                       bar_perc="  ${bar_proz}% "
                       bar_perc=`expr "${bar_perc}" : '.*\(.....\)$'`
                   fi
                   # END PERC
                   # BEGIN ETA
                   if test "x${BAR_ETA}" = x1
                   then
                       bar_diff=`eval "${BAR_GET_TIME}" 2>/dev/null` || bar_diff=0
                       bar_diff=`expr ${bar_diff} - ${bar_t0} 2>/dev/null` || bar_diff=0
                       bar_100p=`expr 100 - ${bar_proz}` || bar_100p=0
                       bar_diff=`expr ${bar_diff} '*' ${bar_100p}` || bar_diff=0
                       bar_diff=`expr ${bar_diff} + ${bar_proz}` || bar_diff=0
                       bar_diff=`expr ${bar_diff} - 1` || bar_diff=0
                       bar_diff=`expr ${bar_diff} / ${bar_proz} 2>/dev/null` || bar_diff=0
                       if test "${bar_diff}" -gt 0
                       then
                           bar_t_unit=":"
                           if test "${bar_diff}" -gt 2700
                           then
                               bar_t_uni="h"
                               bar_diff=`expr ${bar_diff} / 60`
                           fi
                           bar_diff_h=`expr ${bar_diff} / 60` || bar_diff_h=0
                           if test "${bar_diff_h}" -gt 99
                           then
                               bar_eta="     ${bar_diff_h}${bar_t_unit} "
                           else
                               bar_diff_hi=`expr ${bar_diff_h} '*' 60` || bar_diff_hi=0
                               bar_diff=`expr ${bar_diff} - ${bar_diff_hi}` || bar_diff=0
                               bar_diff=`expr "00${bar_diff}" : '.*\(..\)$'`
                               bar_eta="     ${bar_diff_h}${bar_t_unit}${bar_diff} "
                           fi
                           bar_eta=`expr "${bar_eta}" : '.*\(......\)$'`
                       fi
                   fi
                   # END ETA

                   bar_char=`expr ${bar_pos1} / ${bar_want_bps}` || bar_char=0
                   while test "${bar_char}" -gt "${bar_cur_char}"
                   do
                       bar_graph="${bar_graph}${BAR_C1}"
                       ${BAR_ECHO} "${BAR_E_C1}" "
${bar_trace}${bar_eta}${bar_perc}${bar_graph}${BAR_E_C2}" 1>&2
                       bar_cur_char=`expr ${bar_cur_char} + 1`
                   done
               done
           ) | eval "${BAR_CMD}"
           bar_pos=`expr ${bar_pos} + ${bar_size1}`
       done
       # ${BAR_ECHO} "${BAR_E_C1}" "${BAR_R}${BAR_E_C2}" 1>&2
   fi

   if test "${bar_shown}" = 1
   then
       # BEGIN TRACE
       test "x${BAR_TRACE}" = x1 && bar_trace="${bar_t_space} "
       # END TRACE
       # BEGIN ETA
       test "x${BAR_ETA}" = x1   && bar_eta='      '
       # END ETA
       if test "x${BAR_CLEAR}" = x1
       then
           # BEGIN PERC
           test "x${BAR_PERC}" = x1 && bar_perc='     '
           # END PERC
          bar_lauf=0
           bar_graph=''
           while test `expr ${bar_lauf} + 5` -le "${BAR_WIDTH}"
           do
               bar_graph="${bar_graph}     "
               bar_lauf=`expr ${bar_lauf} + 5`
           done
           while test "${bar_lauf}" -lt "${BAR_WIDTH}"
           do
               bar_graph="${bar_graph} "
               bar_lauf=`expr ${bar_lauf} + 1`
           done
           ${BAR_ECHO} "${BAR_E_C1}" "
${bar_trace}${bar_eta}${bar_perc} ${bar_graph} 
${BAR_E_C2}" 1>&2
       else
           # BEGIN PERC
           test "x${BAR_PERC}" = x1 && bar_perc='100% '
           # END PERC
           bar_lauf=0
           bar_graph=''
           while test `expr ${bar_lauf} + 5` -le "${BAR_WIDTH}"
           do
               bar_graph="${bar_graph}${BAR_C1}${BAR_C1}${BAR_C1}${BAR_C1}${BAR_C1}"
               bar_lauf=`expr ${bar_lauf} + 5`
           done
           while test "${bar_lauf}" -lt "${BAR_WIDTH}"
           do
               bar_graph="${bar_graph}${BAR_C1}"
               bar_lauf=`expr ${bar_lauf} + 1`
           done
           ${BAR_ECHO} "${BAR_E_C1}" "
${bar_trace}${bar_eta}${bar_perc}${BAR_L}${bar_graph}${BAR_R}${BAR_E_C2}" 1>&2
           ${BAR_E_NL} 1>&2
       fi
   fi
}
####>-SCHNAPP-<########################################################


BAR_AWK_0=''
# Command line interface:
while test -n "$1"
do
   case "$1" in
       -o|-c|-w|-0|-1|-e|-d|-b|-s|-\[\]|-\[|-\]|-T)
           if test -z "$2"
           then
               echo "$0: Error: A non-empty argument was expected after $1" 1>&2
           fi
           BAR_ARG="$1"
           BAR_OPT="$2"
           shift
           shift
       ;;
       -o*|-c*|-w*|-0*|-1*|-e*|-d*|-b*|-T*)
           BAR_ARG=`expr "$1" : '\(-.\)'`
           BAR_OPT=`expr "$1" : '-.\(.*\)$'`
           shift
       ;;
       -h|-n|-p|-D|-D-|-q|-V|-t|-E|-L)
           BAR_ARG="$1"
           BAR_OPT=""
           shift
       ;;
       --) shift
           break
       ;;
       -*) echo "$0: Error: Unrecognized option: $1" 1>&2
           exit 1
       ;;
       *)
           break
       ;;
   esac

   case "${BAR_ARG}" in
       -h)  echo 'Usage: bar [-n] [-p] [-q] [-o FILE] [-c CMD] [-s SIZE] [-b SIZE]'
            echo '           [-w WIDTH] [-0/1/[/] CHAR] [-d DIR] [-e EXT] [Files]'
            echo '       bar -V'
            echo '       bar -D'
            echo '       bar -D-'
            echo 'Options:'
            echo '     -h         displays help'
            echo '     -o FILE    sets output file'
            echo '     -c CMD     sets individual execution command'
            echo '     -e EXT     append an extension to each file'
            echo '     -d DIR     prepend this prefix to each file (a directory must end in /)'
            echo '     -s SIZE    expected number of bytes.  Use for pipes.  This is a hint'
            echo '                only that must be greater or equal to the amount actually'
            echo '                processed.  Further, this only works for single files.'
            echo '     -b SIZE    maximal block size (bytes) (default: 1048567)'
            echo '     -w WIDTH   width in characters        (default: terminal width-3 or 76)'
            echo '     -0 CHAR    character for empty bar    (default: .)'
            echo '     -1 CHAR    character for full bar     (default: =)'
            echo '     -[ CHAR    first character of bar     (default: [)'
            echo '     -] CHAR    last  character of bar     (default: ])'
            echo '     -n         clears bar after termination'
            echo '     -t         traces (=displays) which file is processed'
            echo '     -T WIDTH   no of characters reserved for the file display of -t'
            echo '     -p         hides percentage'
            echo '     -E         hides estimated time display'
            echo '     -q         hides the whole bar, be quiet'
            echo '     -D         tries to dump the bar_cat() shell function, then exit.'
            echo '                Here, -t, -p, -E remove the corresponding feature completely.'
            echo '                Further, -L removes large file support from the code.'
            echo '     -D-        same as -D, but dumps the function body only'
            echo '     -V         displays version number'
            echo '     --         end of options: only file names follow'
            exit 0
       ;;
       -n)  BAR_CLEAR=1
       ;;
       -L)  BAR_LARGE=0
            BAR_AWK_0="${BAR_AWK_0} /END  *LARGE/ {x=1} ;"
            BAR_AWK_0="${BAR_AWK_0} /BEGIN  *LARGE/ {x=0} ;"
       ;;
       -t)  BAR_TRACE=1
            BAR_AWK_0="${BAR_AWK_0} /END  *TRACE/ {x=1} ;"
            BAR_AWK_0="${BAR_AWK_0} /BEGIN  *TRACE/ {x=0} ;"
       ;;
       -T)  BAR_TRACE_WIDTH="${BAR_OPT}"
       ;;
       -q)  BAR_OK=0
       ;;
       -p)  BAR_PERC=0
            BAR_AWK_0="${BAR_AWK_0} /END  *PERC/ {x=1} ;"
            BAR_AWK_0="${BAR_AWK_0} /BEGIN  *PERC/ {x=0} ;"
       ;;
       -E)  BAR_ETA=0
            BAR_AWK_0="${BAR_AWK_0} /END  *ETA/ {x=1} ;"
            BAR_AWK_0="${BAR_AWK_0} /BEGIN  *ETA/ {x=0} ;"
       ;;
       -V)  echo "bar v${BAR_VERSION}"
            exit 0
       ;;
       -D)  echo "BAR_VERSION=${BAR_VERSION}"
            awk "${BAR_AWK_0}"'{sub(/ *#.*$/,"")} ; /^bar_cat/ {x=1} ; {sub(/^  */,"")} ; /./ {if(x)print} ; /^}/ {x=0}' "$0"
            exit 0
       ;;
       -D-) echo "BAR_VERSION=${BAR_VERSION}"
            awk "${BAR_AWK_0}"'{sub(/ *#.*$/,"")} ; /^}/ {x=0} ; {sub(/^  */,"")} ; /./ {if(x)print} ; /^{/ {x=1}' "$0"
            exit 0
       ;;
       -o)  exec 1>"${BAR_OPT}"
       ;;
       -c)  BAR_CMD="${BAR_OPT}"
       ;;
       -b)  BAR_BS="${BAR_OPT}"
            if BAR_RAW=`expr "${BAR_BS}" : '\(.*\)k$'`
            then
                BAR_BS=`expr ${BAR_RAW} '*' 1024`
            elif BAR_RAW=`expr "${BAR_BS}" : '\(.*\)M$'`
            then
                BAR_BS=`expr ${BAR_RAW} '*' 1048567`
            fi
       ;;
       -s)  BAR_SIZE="${BAR_OPT}"
            if BAR_RAW=`expr "${BAR_SIZE}" : '\(.*\)k$'`
            then
                BAR_SIZE=`expr ${BAR_RAW} '*' 1024`
            elif BAR_RAW=`expr "${BAR_SIZE}" : '\(.*\)M$'`
            then
                BAR_SIZE=`expr ${BAR_RAW} '*' 1048567`
            fi
            if test "$#" -gt 1
            then
                echo "Error: -s cannot be specified for multiple input files." 1>&2
                exit 1
            fi
       ;;   
       -e)  BAR_EXT="${BAR_OPT}"
       ;;   
       -d)  BAR_DIR="${BAR_OPT}"
       ;;   
       -0)  BAR_C0="${BAR_OPT}"
       ;;   
       -1)  BAR_C1="${BAR_OPT}"
       ;;   
       -\[) BAR_L="${BAR_OPT}"
       ;;
       -\]) BAR_R="${BAR_OPT}"
       ;;
       -\[\])
            BAR_L="${BAR_OPT}"
            BAR_R="${BAR_OPT}"
       ;;
       -w)  BAR_WIDTH="${BAR_OPT}"
       ;;
    esac
done

# Invoke main function:
if test "$#" = 0
then
    bar_cat /dev/stdin
else
    bar_cat "$@"
fi
