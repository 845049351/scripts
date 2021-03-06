#!/bin/bash

########################
#  FSCP v1.0 by imbugs #
########################

baseDir=$(cd "$(dirname "$0")"; pwd)

configDirName=.fscp
configDir=$HOME/$configDirName
binDir=$configDir/bin
lockDir=$configDir/.lock
config=$configDir/list
sshpass=$binDir/sshpass
fscpcmd=$binDir/fscp.sh
rbinDir=$configDirName/bin
rfscpcmd=$rbinDir/fscp.sh

sshparam=" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "
leaf=3;

help() {
	cat << EOF
Usage: $0 file(directory) [user1@ip1:passwd1] [user2@ip2:passwd2] [...]
	you can alse to edit config file $config, example:
	user1@ip1:passwd1
	user2@ip2:passwd2
EOF
	exit;
}

log() {
	time=`date +'%Y-%m-%d %H:%M:%S'`
	echo "[$time]" $@ >> $configDir/log
}
if [ $# -lt 1 -o $# -lt 2 -a ! -f $config ];then
	help
fi

file=$1
if [ ! -e $file ];then
	log "[ --- ] File Not Exist [$file]"
	exit 0
fi
rpath=$(cd "$(dirname "$file")"; pwd)
[ -d $file ] && rpath=$(cd "$file"; pwd);
# remote relative path to home
rpath=${rpath#$HOME/};
log "[ --- ] Files Will Be Copy To Remote Directory [$rpath]"

shift
ips=$@
[ $# -lt 1 ] && ips=`cat $config`;
ips=($ips)

extract() {
	rm -rf $sshpass;
	mkdir -p $binDir;
	ARCHIVE=`awk '/^__ARCHIVE_BELOW__/ {print NR + 1; exit 0; }' "$0"`
	tail -n+$ARCHIVE "$0" | tar xzvm -C $binDir > /dev/null 2>&1 3>&1
	if [ $? -ne 0 ];then
		log "[ --- ] Extract Binary SSHPASS Fail"
	else
		log "[ --- ] Extract Binary SSHPASS Success"
		chmod +x $sshpass
	fi
}
[ ! -e $sshpass ] && extract
[ ! -e $fscpcmd ] && { cp -rf $0 $binDir; chmod +x $fscpcmd;}

rexec() {
	pIp=$1
	pPw=$2
	pCmd=$3
	log "[REXEC] [$pIp] $pCmd"
	$sshpass -p $pPw ssh $sshparam $pIp "$pCmd"
}
# rsync SCP
rSCP() {
	log "[ RSCP] Not Support"
}
# normal SCP
nSCP() {
	pFile=$1
	pIp=$2
	pPw=$3
	pDir=$4
	param=""

	log "[ NSCP] $pFile => $pIp"

	if [ -d $pFile ];then
		param="-r"
		pDir=$(dirname $pDir)
	fi
	log "[LEXEC] $sshpass -p $pPw scp $sshparam $param $pFile $pIp:$pDir"
	$sshpass -p $pPw scp $sshparam $param $pFile $pIp:$pDir
}
# gzip SCP
zSCP() {
	pFile=$1
	pIp=$2
	pPw=$3
	pDir=$4
	log "[ ZSCP] $pFile => $pIp"

	if [ -d $pFile ];then
		cd $pFile
		tar czf - . | $sshpass -p $pPw ssh $sshparam $pIp tar xzf - -C $pDir
		cd - > /dev/null 2>&1 3>&1
	else
		fileName=$(basename $pFile);
# use gzip
		gzip -c $pFile | $sshpass -p $pPw ssh $sshparam $pIp "gunzip -c - > $pDir/$fileName"
# use tar
		#cd $(dirname $pFile)
		#tar czf - $fileName | $sshpass -p $pPw ssh $sshparam $pIp tar xzf - -C $pDir
		#cd - > /dev/null 2>&1 3>&1
	fi
}
# bzip2 SCP
jSCP() {
	pFile=$1
	pIp=$2
	pPw=$3
	pDir=$4
	log "[ JSCP] $pFile => $pIp"

	if [ -d $pFile ];then
		cd $pFile
		tar cjf - . | $sshpass -p $pPw ssh $sshparam $pIp tar xjf - -C $pDir
		cd - > /dev/null 2>&1 3>&1
	else
		fileName=$(basename $pFile);
# use gzip
		bzip2 -c $pFile | $sshpass -p $pPw ssh $sshparam $pIp "bunzip2 -c - > $pDir/$fileName"
# use tar
		#cd $(dirname $pFile)
		#tar cjf - $fileName | $sshpass -p $pPw ssh $sshparam $pIp tar xjf - -C $pDir
		#cd - > /dev/null 2>&1 3>&1
	fi
}
getIp() {
	echo $1 | cut -d':' -f1
}
getPw() {
	echo $1 | cut -d':' -f2
}
split() {
	gId=$1
	[ "$gId" == "" ] && return 0;
	length=${#ips[@]}
	groupFloor=`echo "$length / $leaf - 1" | bc`;
	groupSize=`echo "scale=2;$length / $leaf - 1" | bc`;
	if [ `echo "$groupSize > $groupFloor"|bc` -eq 1 ];then
		groupSize=$(($groupFloor+1))
	else
		groupSize=$groupFloor
	fi
	idx=`echo "scale=0;$groupSize*$gId+$leaf" | bc`
	#echo gId=$1,length=$length,groupSize=$groupSize,idx=$idx0
	echo ${ips[@]:$idx:$groupSize}
}
lock() {
	pIp=$1
	[ ! -e $lockDir ] && mkdir -p $lockDir
	touch $lockDir/$pIp;
}
unlock() {
	pIp=$1
	[ ! -e $lockDir ] && mkdir -p $lockDir
	rm -rf $lockDir/$pIp;
}
handle() {
	pServer=$1
	pIps=$2
    pIp=`getIp $pServer`
    pPw=`getPw $pServer`
	log "[ >>> ] $pIp"
	# mkdir remote path and fscp config path
	rexec $pIp $pPw "mkdir -p $rpath $configDirName"
	# scp fscp runtime
	nSCP $binDir $pIp $pPw $rbinDir
	# scp files
	nSCP $file $pIp $pPw $rpath
#	zSCP $file $pIp $pPw $rpath
#	jSCP $file $pIp $pPw $rpath
	if [ "$pIps" != "" ];then
		# run remote fscp
		if [ -f $file ];then
			fileName=$(basename $file);
			rexec $pIp $pPw "$rfscpcmd $rpath/$fileName $pIps"
		else
			rexec $pIp $pPw "$rfscpcmd $rpath $pIps"
		fi
	fi
	unlock $pIp
}
for i in `seq 0 1 $(($leaf-1))`; do
	if [ "${ips[$i]}" != "" ];then
		lock $pIp
		splitIps=`split $i`
		handle ${ips[$i]} "$splitIps" &
	fi
done;

while [ -d $lockDir ] && [ `ls $lockDir | wc -l` -gt 0 ]  
do
	log "[CHECK] `ls $lockDir | wc -l`"
	sleep 1;
done
log "[ === ] FSCP FINISHED SUCCESS"
exit 0;

#This line must be the last line of the file
# tar -zcvm sshpass >> fscp.sh
__ARCHIVE_BELOW__
� ?��Q �|tTE�v�>�IC��r@PФIbx;
�������t��4t����QFA�Q�p��\�љ�u|�3:(��rud���x��3p�f|�N���������Z��J�W�k�]��NU�I$��?�`�LWFn����'�/���*'L(�`��&L��l|e9++�(��dZ�?U+�	��4f�"����t/���0k�lEQ���T�f��]I�3SD:5�gc�h6��qL~#ѐ?Nqxy'y�|b���ߏp?��H���_:�1x�gE"��=Ny�c���|��wP��0��"�'e��!�1$^#�������V�q�P��p�4�$�zQo�H/��Ϲ�N�Jx�=Zz&e����`[�G��E�o���䇓���M������|1��}ȟG~(��ҮCr�`w��QO5;s���g����u��\GM�0a�B�v�w���\&l���%����%'z�Ć�/p������k$���{$�H��?R�@�%6%*����<���tÖ}���9�J�[%�/�b�WJ<T��x��M��w_&�O�x��o��Y��D�J�~U2�J�;%���wH���$�L�ȿi����=��:$�~i�̌#�����?$���)����w��"�1�0�xU�iz��|�Mш3���1��	��2c� Ef��⡈���F�)f�K�&k�M=��$̸��@�G�D����8�%�k��� �ƈ#���A�E���hL��L�"A���j�D>q���k��WC&�Ƹ?bR3��b	=���$٬�92u����7��E|Ʉv���n�?aЁH���#�T�@��G:t�ţ�&b5�3ތ*_���[����c�0��?����������ga,��wÐP�B��V
����p�`Kd���~�7J�7W/��\�D�qѤ9��|������|�$�!u�Z�4�-EH�
�4�]��&� B��@H�x!M�1�4A�i�^��&��Iэi�ތ�:��4A߁�&����~!M��#��|'B�,BH�"�I�q�4�?�� O!���3i�ߋ�uml9�N����L�[Bʾ��u���(�FO���[�hX�ϔǻȍ���u��2`�}�b��8�����8��1��9�%,�:6r���cò�4��9��L����F5�4�aqc)pǰ�q=��1Z�@�:�8FK1`�1Z�X��-0Z�����1Z�����1Z�����1Z̸�ןc����?�hA�q^�ђ�S���E�����e�}�����C�����ü��ō��������)^���u]�Z>]d���ӿ�����r�SÉ���۩�Ԡ [�i�ԗmk��rZ�����K���;�����{�ߘ�'���a-������td7�mE�G�'�@�����(�۠���:3����H�:��Z� N��XK��Tꛮ.Y~��mI��Y����+�p��"��������n�l���9lkޤC���W�ܾ*��|$�D��:���)�Vu�ςO�����>kouWҝz�lC�[��,��}�N���ΛGoo=��q���=��D�h��%zO�3�H����c���g�W)�����w����ϸȗ1U�8
�$�h�I�F�e�J��h9�(��F$-gT��]?��ʐ�jV�T]WI&.�6���~��~���q?����-\T�
}:�T�&�����*�(���Ol9��vм�S�Q��nv�et�CIʒe`��I�Ͳ�42�ʽ50�nb�5�QV��$��@j�	�6�E
{���w��ۼ�/�&�i;�C�Rۃ���A�19	t��#��Nu�?Npq���X�N��lܻ�@V��`��k-�B�M'�!.�17{����W�Im��D9Ga�����-�<�">��J^d`u��Y��=�v�GV�o_�R�:�������u:C�dt�4-�p��(��k�waL��j�I�*K�ܼ[��l&Ym�S�,�m��T�p����8��pPX�z���ֺ���[S��ˠf9غ��e�sT�>��J�E��kW��I}���3�f�#5���O��2�����3T���m�����ߞ���^}�Ϯ�����|/(I!�z�_��V����k��n��/y��*H�e�޷y_r.��v�ku׳�djj�ΛM�ȶ{���v�6��ڧ+��l�Wx絘�N�u޲�gd���%ߤ���-�2]��YX)u��U(S$L���o)�#*�:զ�^/|k/�x��nc>:Qqjg�1�SKJ!~�yG%���Xq/%�<#炽X�E�;(��ǈ=���F�p��n�U����ЋZ�b�L�h;�Nٰ!��J�LD�|'zls����1c��?'>�;�	v��F~���h���C��V�9e�o=�ќp��eL2]'�c�Sƶ/4��nIj����k[��J&ZRSZ�Lh>�5�u-m���֊.B�1c��i�d��}�]�b[5�f�A?��b�Z6��E�5���o��N�S�eA��e�m_����H�M�<������Ufj�S1�-�W�T���bjI�j�$��G6Nb'zp�ȓfl���%;;N`�;��1i���f'�<��9����T��T��h�\eI��9�:��X����v�7"��Ә�����``����CL�۾=��;R.�;�����Np9�0,�;6`4UY�|�8U�z���۾��#������`�xL���V70��� �YC+Od�,�W�5���b�nZ0��~N�Z��k���fu�=\~�3���ާ�I���-����W�pL~����_h(�.a���tb(y��Ǟ!6$�=�uµ����W�ӟNy�1�~Z�3�J�ƿ=�6:��:�M�^��K(���x��s�a������F}��ۯ��҆���������JB��Z �����?N�����iZi��
�x5$T�_�k���53�ы���6q"N�"ɦz=���Q����тz"��h\��P��B�ՙf�y�224�:]
��'zN6�S��IzC]�%#͡�>���5���ʅ���9��v�\YS3�zzM�H\2-��@+��m��Z���d���5��ev�5F�Y3�pLc$�������,���!I�hDE�$M~��=��ZS4ajш�E�Jȶ%�Y�j�0��p��qr��d_�*�i$�%�d0�Q=�B�"�?�	�ʢ����<��4�Y$�CM�l����I����}=�8]<����SͰ�A�h�!3�'MM6�,�Fx�Sۅ��ԟ"QSK�&�7�Nhc��jeeJ+��˵�Ա"I��&�]��F�0�q�͠�g-Z��l�Gi�v�����K4���?+C	3"uH�d$H=�4tn��`N���5T�k��ͻz�����MѸno`oO6.��g���%S�SbS}1�u���{��3Һ!
d�5�z˄)�����$=b����>D3�v��(ǟ+���߰����"*7��Y~�����v���%��VȘ����{ܯ��tc�V����t����f�k���:��?�+b��֞��I�}J�[�����t#���'�2{�P��RQ��I�(t���ۜ��������Juql!y�G�� ?��"�����o%7���?M�U�G�D�S�6*O~$�
�3�/"_O>N�V�w�����_m��B�9UUS�1s���]��N�î���R��F�\�)�K��Ʋu��7Ԥ7�L�م8�0�:�#l��@:=u�:"�� `�W)�wY}۾� �沧��iF��hҌ%MVO]��O9o��n�
E�#=�\(�6��z"t������$B�#L����o��k{���۞���	*PAHy�!N��S��v�ԫhX8�Ul�+n�9�櫳E�	$橿#�p9�	ǜ.uʺ����w���9ՏbS!�.,r�v��;�f;�Hň�6#ѱ4�!��|�ri��)[އB>"Q#8s����������>��R�[��"��a��0�Am�?�}d��hޅ p<�S���,oE7�]�� )ys�8�ي8{��|�쫇SJOg����k=,��2\�_.��7 ȑ?�h\�@�|<�]#�cKUq*���^�)",�(�
.���iA�Q�����n�)Le�$�x���E����]�`���<?���$,����$�<̀C$�Y ���`[P,a��6�q��}�2ϝ�Ք�8����
F�M���Jx�g:8�Qn�p��1�E�f�g`�2��ٞ&h�U~�9��`���By�ù�Y ������{>��,��X��p��K=	Xc��+<7Α�zO��*�9��g �^)u6<�;_��冩�^G�^訽@�TL�aO�s�������!h���[���炯��B�q�S�Q���� F�;�ԋX�g0ʌ���+څ�\TH�9�|7��0'����2=��>�,~��	Ae6Y�"t+s�ql��xG��Q�2�3�.��U�4n�*�0�)�H�.�[h�&_B�G �N"��>�F7x��M
 /|0<�1eGWa��Y��п�)
����t��)��"'����_g�#��|��g1ӱb��>ގꎧ6@�+���r�y����r&i�
=�(����t���`�ݜt*�Q�o�=���O�&ќ�ԣ|�0���?M���C�ɟ,~�Tlp?�B2��ŏ�S��Y��	e�27)�S-n���J��MPQ�h��q�dJ�s�Z�s\���7tq��ܬ��^iO�z- |�p7:tx���*��]N�r"~��G��c8D�w)�m����Q����#J��'�'#����0��W҉�N.��	��p|'0c�X�<�+��1]�i�x�҃K;~K�Ŏo�3�1<�_C�$e��X?�%�&Fl"�3������Ta
�\F�C��0V���GTKA9�f���|/��p�Qb���n%?�W��K���n)�p����l�ϗ؃����?�r��EkN�d?�BW�%�`6�"��%�V_N��K�0�����p ����Q�<Z)�ʳ��Q$Oγ��Q0���X'��8r/�Ei���8��KNS�-P�^O	%�(�(�(D�_�&#�"�ޒi���^�WQ,�C�i(�%�����ݥ\r�K���z��rJ��(�r��2��2�˸�ˠ��ב���8#WV��~{T7a���aإ�d����j(�0��)��:��@�|jc�X�)�`ڜ�(���+y��}�"��"�3�E���尢`��N�#����+�ZLh;X1.o+/��G�;���U�]`u� ]�U�M� �1UR�	���f޵�Ú�N>�(6 �%�o(�]��"����R���uIyILCؠ�p઼,�%ǔ>JQ^_�?�w����ޤ�@���R0�`�M��\N/fN��E�U�
xv^?E�WP j���'��C��@�c��o�D1�2R���(��\�X�
���`��iR4�ҋ�}��y�Ծ�l:�#�@���C�ju�^*w�G���3���1Е��A�J�E�A�ŬB�m�H�!�Y<�(uWfseq>�ƹ���pW�R��*3������Y@\ �D����EDF�mE3ʅ{���+��^�60��fҋ��r⿴`��+�ԒJ
 �t�R�e�l���q^��V�4�(s٘�W�ګ�Ӡ. �+s�
Eǻl�O�(y��2Z�N�'�L��7��=�?���K&��B�@8ԙ�K�Kd'ԇL��낍���Х�&�����7���q�]4͏�z�:f�Jy쉘�bz���L��,��TjK׀�9&tS�����@q��
�`��Ш��(+J�ԁ��S��~�;��oRo|P-أ6o������jK�̞�5|���u�7�2E��6�Р�����>Щ���/)٩���u]���w@�����ta��KK�!J�����pk�/-�q�����7���I�=��n��~��u�/��C������[7�R��T{]��ֽ�y��j�;S)�Urq�Z��=���O{�j-��U[6���w��lP��:uF�zy���-��ă���zpɏ6���w�~��ĦԶﴫ�lh_�S�l�z���L�y���%j��{�ڳn�����^�T�m84i���uW�g���Q�n8���Pw;꜊��7?x��ʃ~u��έ���W���V{�_G~��{�/�����;�7ݻ��s���q|O�c
Sֻ=N'�1��Fؿ�������5����L�����Z\�9i���|,�M[�l���H��aA���fVQ��9�^vZtX���l^�Zo�Zo�uGkG����'�xݫ�E�dū�D̻��*o�Y��q�&��N��V����x�ΰ�1�E����J|�R����J����'t�E,��c�w\<5��=�R���/����>=��tц��b��,Ђ�ɏ˅��g�M�U/���a6�Ys·.Z��Y ����r�7�!V�l���l	A��JJ�"13�S����z�%�h�Ԓ\ԃ6kĝ�`�$%l�L(4{��Y,ML"����so<�})I�W�%�l֪��}�D�E����gd~
����d�9[j�W�������d��Acq�{�D-oQ�u��#ݾ��H&��!�oLTp����/DS�Z&�8������$���5&N.,:jȵ�!}�p�J�z`u2f5\���<kO6���[>�4j�����_��8��q_ N6��A�DPWD�bq}�آ�QՉ*D@=ط��v`�hDg���?����m��;B�#z��o\���ޏ뱾PЦxVw��%�Z�T(s�����-q�$^	ʎG����jB%��ۜ|�� ���F�N5�3�]���[I6���M�{�b�u�y�'\��K]�j2�O�������Ac�4�IqKi٧L>�H(W	�S��4Nc��"�øh�KEP�'%<s�䛸���{}y<�ގ�$6@�"<O�"\qڱ<mq9��I�:YLI�,祦�RN��gA��g]F��^�\��3�l�ܶrE�rRK��qu����֊�ڌ��3�W[��~��'�drk�\���x}�x���K��~�|����r�d�͈�}M����s�%��%V.��RK��H-�+�Z���RK�_A��
#��d}$�q��`�LFخdi�;�_
�c���V#H(Y�o'�C�#�G��/wd+ڷ��[��Ǟ�ǂ��(�̑%�'�����xt1';��a���*w#���E��&�P	a\�����v�d����-G�d�Dxg��3��9�%�g�y2���U���A�A�=���W�0�T�J�*K]o%��$�����āŁ�*nVy�����%/B0�)�)�j,B��JG�n�n��F	�a��TD�҄��۹�j�S����#)�PD�|�3k�$��E�)5+w;�Wy�B��0:T�&���6�8������6Ѥ�������ͱ�,�ؕ��7��6W��.�c&D܍����]��"��q�y��/�y2���������
fΟf�����)�z.`1���K/�0J����x��Ga-/S�c"z�V�̛�Y���OC�G����e��6_��"�F8ĝm�b�sZ��E܍pD-��'��U�a�q3i"���[N���h8������s�[I���{��~z;���+��v�ĺ&ZdRHKV���(Ƽ���{�ϘWj����'���PAҒ�K�����|��à�-Z�s���X^{PV4�7�̫�ܨbހ���7(�U�8�o
H@���7Q���^��#H�듍�~����c�z�L�1�ؤI��ik�p�֨2.��WV�DVT���΍��K�UwA,gu�X�w��7�J���X��$��%�2%�o��t"wV@�{,k)R�e��-��Z�{/���K�~s�'���U.��ӳ�Z�C��[I�{.&�Mc�r��C��=�g�2���ꁡ���^ͻy⾍S�ϢKJ�����Z�X���/f�;Ftǈ�Sɦ���F��!�IJl�q6�M6:�#���[X��v��1����γ�����O�e�6֊? ��v�7ʃ�3k�=d�������lt����r��u��� 1ùlt����~+W9�l~�/��p�j�m>�~�ω����\�^��A�[Ň���to�L߆]�s���s���Vޟr�&�]�;�C��Pq�'�Ρd�����g��НC�;]q��K�?��{�����S;F��dk8E��~+ibZ��MwE�o&�ʉ�M��r�-�a2㿽̥��F��;�/���2�Z�~+�Q.�s9�ӌ�Tc�XH���B�W���0�
,Z��T��x3����Ic12�Mc1�`>Xt�ci\��m#���8��qo����/�>na��|}���Hc�ŀp�'Y��]�Ii,nK�<�
���}�����!9xh.���r��9xx�r��<2_��G��)��A��ǖ�d킆����~1��[!j�P�H�|��=��Q���чB��FD��y�)�����7S��&sm�&?���B��_s����{2�_��g�un�||SwQ�R��Sx̆?���َ[(=8���;(C$Σ��l�x��a��70���
�o"���2����s��W�|�7��%���V�xr2�M��̷���*���\-����=�M�[߀x^b��+��Q��k��������po�<� �Ӳ�����ܚ/��|�KN��7$4��oHTHl}Cb�#�����:���B����[d~���.��͈����ī[ߘx7���#���O�Iy���9�`53�Q�f�x��|(X߬��f��ek��h�$��M����_���z�̷�q��#�m��9��������J�����y�?R������72z�g�����[�ȸԙm�����>4?W�̖�����/���ol����npfsc�3�����77�vf�[D���mm��'��3��_IzC�S�ʶ�pW6?��öOp�@�L�Ɇz��j�Y�?����#43]Y�1o?Q	����#�5����������ɵ��=��ɦ�u�YW��p���E��J#�����4Wy@���O��R���k�_x+��~�K�g@��̩�<z����6-�m~"��aO��\v����iW&�L|�Þ�k���f�y{>-bǹ�U�K'98���������'�DT��>;H$9�6JVi�!?cb��O�ͿQ���O{�)�ǈ�K.Y�Dgw!r*&�В]��O��3ŧSrxX�L�N	�6�p�N,}�z�^���س�ܒ��m��N�,->]����+/YV;�a��0Y~�&[2u��YG���L�u�O�d�1����ɤ���m&ߜ��̘>�w���5�j}��g̟E����'��F��vYD���i8kXQ�����_ʶHZ�����܏}4��0[X�׉�]��vݮ�u�n���]��vݮ�u�n���]��vݮ�u�n���]��vݮ�u�n���]��vݮ�u�n���1�?�M�� x  