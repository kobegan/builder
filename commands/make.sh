__file__=$(echo ${BASH_SOURCE[0]} )
__dir__=$(cd $(dirname ${BASH_SOURCE[0]}); pwd )
__builder__=$(cd $__dir__/..; pwd )
__lib__=$(cd $__builder__/commands/lib; pwd )
__config__=$__builder__/config.ini

__arch__=x86_64
__platform__=windows
__debug__=
__WD__=$PWD

[ "x$(uname)" == "xLinux" ] && __platform__==linux



function _home(){
    
    local inifile=$($__dir__/lib/inifile)
	local config=$($inifile.open $__config__)

    local section='cerbero'
    if [ ! -z $__custom__ ]; then
	   section="cerbero.${__custom__}"	   
	fi
	d=	
	if [ "x$(uname)" == "xLinux" ];then
		d=$($config.get $section home.linux)
	else
	    d=$($config.get $section home.windows)
	fi
	
	if [ ! -z $__custom__ ]; then
	    cd $(dirname $__config__)
		[ ! -z $d ] && cd $d
	    d=$PWD
	fi
	echo $d

}


#recipe param
__source__=
__recipe__=
__custom__=
__cbc__=
__home__=

BS_configure=
BS_compile=
BS_check=
BS_install=
BS_all=Yes
echo $@
function options(){
	while [ ! -z $1 ] ; do
	 opt=$1
	 case $opt in
	   --source)
		  __source__=$2; shift 2
		  echo $__source__ "SOURCES"
	   ;;
	   
	   --recipe)
		  __recipe__=$2;shift 2
	   ;;
	   
	   --custom)
		  __custom__=$2;shift 2
	   ;;
	   
	   --cbc)
	      __cbc__=$2;shift 2
	   ;;
	   
   	   --configure)
	      BS_configure=$1;shift 
		  BS_all=
	   ;;

   	   --compile)
	      BS_compile=$1;shift 
		  BS_all=
	   ;;
   	   --check)
	      BS_check=$1;shift 
		  BS_all=
	   ;;
   	   --install)
	      BS_install=$1;shift 
		  BS_all=
	   ;;	   
	   *) 

	   break
	   ;;
	  esac
	done
	
	[ -z $__recipe__ ] && echo recipe name must be specified! && exit 1
	[ -z $__source__ ] && echo source directory name must be specified! && exit 1
	[ -z $__cbc__ ] && echo cerbero config must be specified! && exit 1
	
	__home__=$(_home)
	echo "@@$__home__"
    if [ -z $__custom__ ]; then
 	  if [ ! -f $__home__/config/$__cbc__ ]; then
 		  echo "can not find cerbero config $__cbc__"
 		  exit 1
 	  fi
    else
	   echo "#$__builder__"
	   echo "!$__custom__"
 	  __cbc__=$__builder__/custom/$__custom__/config/$__cbc__
	  echo $__cbc__
 	  if [ ! -f $__cbc__ ]; then
 		  echo "can not find cerbero config $__cbc__"
 		  exit 1 	  
 	  fi	      
    fi
	
	if [ ! -z $BS_all ]; then
	  BS_configure='--configure'
	  BS_compile='--compile'
	  BS_check=
	  BS_install='--install'
	fi

}



function _fatal(){
    echo $@
	exit 1
}

#$wms build 'name' --compile --configure --check --install --debug
function _make(){
    echo -e "
	----    Build $__recipe__     ----
    
    configure    [ $( [ ! -z ${BS_configure} ] && echo Yes || echo No)]
    compile      [ $( [ ! -z ${BS_compile}   ] && echo Yes || echo No)]
    check        [ $( [ ! -z ${BS_check}     ] && echo Yes || echo No)]
    install      [ $( [ ! -z ${BS_install}   ] && echo Yes || echo No)]	
    
    source location :
    $__source__/$__recipe__
    
    cerbero config
    $__cbc__
	
	"


    cerbero=$($__lib__/cerbero -c $__cbc__ -i $__config__ -u wms)
	echo "================================"
	echo $cerbero
	echo "================================"
	$cerbero.run cpm-build $__recipe__ --directory $__source__/$__recipe__ $BS_configure $BS_compile $BS_check $BS_install
}


options $@
_make

