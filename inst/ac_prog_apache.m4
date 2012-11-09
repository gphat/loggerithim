dnl Available from the GNU Autoconf Macro Archive at:
dnl http://www.gnu.org/software/ac-archive/htmldoc/ac_prog_apache.html
dnl
AC_DEFUN([AC_PROG_APACHE],
#
# Handle user hints
#
[
 AC_MSG_CHECKING(if apache is wanted)
 AC_ARG_WITH(apache,
  [AC_HELP_STRING([--with-apache=PATH],[absolute path name of apache server (default is to search httpd in /usr/local/apache/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin)])],
  [
    #
    # Run this if -with or -without was specified
    #
    if test "$withval" != no ; then
       AC_MSG_RESULT(yes)
       APACHE_WANTED=yes
       if test "$withval" != yes ; then
         APACHE="$withval"
       fi
    else
       APACHE_WANTED=no
       AC_MSG_RESULT(no)
    fi
  ], [
    #
    # Run this if nothing was said
    #
    APACHE_WANTED=yes
    AC_MSG_RESULT(yes)
  ])
  #
  # Now we know if we want apache or not, only go further if
  # it's wanted.
  #
  if test $APACHE_WANTED = yes ; then
    #
    # If not specified by caller, search in standard places
    #
    if test -z "$APACHE" ; then
      AC_PATH_PROG(APACHE, httpd, , /usr/local/apache/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin)
    fi
    AC_SUBST(APACHE)
    if test -z "$APACHE" ; then
        AC_MSG_ERROR("apache server executable not found");
    fi
    #
    # Collect apache version number. If for nothing else, this
    # guaranties that httpd is a working apache executable.
    #
    changequote(<<, >>)dnl
    APACHE_READABLE_VERSION=`$APACHE -v | grep 'Server version' | sed -e 's;.*Apache/\([0-9\.][0-9\.]*\).*;\1;'`
    changequote([, ])dnl
    APACHE_VERSION=`echo $APACHE_READABLE_VERSION | sed -e 's/\.//g'`
    if test -z "$APACHE_VERSION" ; then
        AC_MSG_ERROR("could not determine apache version number");
    fi
    APACHE_MAJOR=`expr $APACHE_VERSION : '\(..\)'`
    APACHE_MINOR=`expr $APACHE_VERSION : '..\(.*\)'`
    #
    # Check that apache version matches requested version or above
    #
    if test -n "$1" ; then
      AC_MSG_CHECKING(apache version >= $1)
      APACHE_REQUEST=`echo $1 | sed -e 's/\.//g'`
      APACHE_REQUEST_MAJOR=`expr $APACHE_REQUEST : '\(..\)'`
      APACHE_REQUEST_MINOR=`expr $APACHE_REQUEST : '..\(.*\)'`
      if test "$APACHE_MAJOR" -lt "$APACHE_REQUEST_MAJOR" -o "$APACHE_MINOR" -lt "$APACHE_REQUEST_MINOR" ; then
        AC_MSG_RESULT(no)
        AC_MSG_ERROR(apache version is $APACHE_READABLE_VERSION)
      else
        AC_MSG_RESULT(yes)
      fi
    fi

    # Find the config file
	#
	#
	HTTP_CONF=`$APACHE -V | grep SERVER_CONFIG_FILE | sed -e 's/.*"\(.*\)"/\1/'`
	AC_SUBST(HTTP_CONF)

    #
    # Find out if .so modules are in libexec/module.so or modules/module.so
    #
    HTTP_ROOT=`$APACHE -V | grep HTTPD_ROOT | sed -e 's/.*"\(.*\)"/\1/'`
    AC_MSG_CHECKING(apache modules)
    for dir in libexec modules
    do
      if test -f $HTTP_ROOT/$dir/mod_env.*
      then
        APACHE_MODULES=$dir
      fi
    done
    if test -z "$APACHE_MODULES"
    then
      AC_MSG_RESULT(not found)
    else
      AC_MSG_RESULT(in $HTTP_ROOT/$APACHE_MODULES)
    fi
    AC_SUBST(APACHE_MODULES)

	#
	# Find Apache's User and Group
	#
	HTTP_USER=`grep ^User $HTTP_ROOT/$HTTP_CONF | sed -e 's;User ;;'`
	HTTP_GROUP=`grep ^Group $HTTP_ROOT/$HTTP_CONF | sed -e 's;Group ;;'`

	AC_SUBST(HTTP_USER)
	AC_SUBST(HTTP_GROUP)
  fi
])
