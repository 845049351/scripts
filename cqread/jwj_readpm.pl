##########################################################
# ִ�У�cqperl jwj_readpm.pl ����[pm����������Ҳ��]
# cqperl jwj_readpm.pl ali00009837[��ĿID]
use CQPerlExt;

my ($DATABASE_NAME) = "bugs";
my ($DATABASE_SET) = "Imbugs";
my ($ADMIN_NAME) = "test";
my ($ADMIN_PWD) = "";

# ����ֵ
chomp(my $input = $ARGV[0]);
# ����ֵ
my $str;

my $session = CQSession::Build();
$session->UserLogon($ADMIN_NAME, $ADMIN_PWD, $DATABASE_NAME, $DATABASE_SET);

if ($input =~ /ali\d+/){
	$str = getProjectDevs($input);
}else{
	$str = getProjects($input);
}

CQSession::Unbuild($session);

print $str;
exit $str;

###########################################################
# ��ȡ��Ŀ��Ϣ
# ���룺PM����
# �����ID:HEADLINE��ID:HEADLINE
# ���û�в�ѯ�������أ�1
sub getProjects{
		my ($pmFullName) = @_;

		my $pm = queryUser($pmFullName);
		
		my  ($qryDef) = $session->BuildQuery("��Ŀ");
		my 	$str;	
			
		$qryDef->BuildField("id");
		$qryDef->BuildField("Headline");	
		
		my ($node) = $qryDef->BuildFilterOperator($CQPerlExt::CQ_BOOL_OP_AND);										 
								 
		$node->BuildFilter("��Ŀ������.login_name", $CQPerlExt::CQ_COMP_OP_EQ, ["$pm"]);		
		$node->BuildFilter("State", $CQPerlExt::CQ_COMP_OP_NOT_IN, ["Closed"]);				
		
		my ($resultSet) = $session->BuildResultSet($qryDef);
        # ��ȡ�û���¼
        $resultSet->EnableRecordCount();
        $resultSet->Execute();
        # д�뵱ǰʱ��
      					
       my($recordCount) = $resultSet->GetRecordCount();                                         
        print "query:$recordCount\n;";
        return -1 if ( $recordCount < 1);
        while ($resultSet->MoveNext() == $CQPerlExt::CQ_SUCCESS) {
                my($id) = $resultSet->GetColumnValue(1);
                my($Headline) = $resultSet->GetColumnValue(2);
				$str .= "$id:$Headline".",";
		}
		return $str;
}
#####################################################################
# ��ȡ��Ŀ�����б�
# ���룺��ĿID
# ���������:ʵ��:����������:ʵ��:������
sub getProjectDevs {
		my ($projID) = @_;
		my $str;
		#print "$projID\n";
		my      ($projectObj) = $session->GetEntity("��Ŀ",$projID);	
		my	@users = @{$projectObj->GetFieldValue("��Ŀ��Ա")->GetValueAsList()};
		#print "@users\n";
		
		foreach my $user (@users){
			my $dev = GetDev($user);
			if ($dev){
				$str .= "$dev".",";		
			}
		}
		return $str;
}

#############################################################
# ���룺����loginname
# ����� ����:1;���ǿ�����0
sub GetDev {
	my ($user) = @_;
	#print "user:$user\n";
	
	my $obj = $session->GetEntity("users", $user);
	my $fullName = $obj->GetFieldValue("fullname")->GetValue();
	my $miscInfo = $obj->GetFieldValue("misc_info")->GetValue();
	my @groups =  @{$obj->GetFieldValue("groups")->GetValueAsList()};
	#print "@groups\n";
	my $wangwang;
	#print "$miscInfo\n";
	if (!$miscInfo){
		$wangwang = "";
	}else{
		$wangwang = getWangWang($miscInfo);
	}
	my $str = "$user:$fullName:$wangwang";
	
	foreach my $group (@groups){	
	#	print "$group\n";
		return "$str" if ($group eq "����");
	}
	return ;
}

sub getWangWang {
	my ($str) = @_;
	
	$str =~ /.*\[(.*)\]/;	
	return $1;
}

sub IndexOf {
	my ($usr, @all) =@_;
	foreach my $one (@all){
		return 1 if ( $one eq $usr);
	}
	return 0;
}
#######################################################################
# �û���ѯ��
# ���룺������������ʵ��
# ���������

sub queryUser {
	my ($queryuser) = @_;
	my $loginName;

	my	($qryDef) = $session->BuildQuery("users");
	my	$users;
	$qryDef->BuildField("login_name");	
	my ($node) = $qryDef->BuildFilterOperator($CQPerlExt::CQ_BOOL_OP_OR);	

	$node->BuildFilter("fullname", $CQPerlExt::CQ_COMP_OP_LIKE, ["%".$queryuser."%"]);
	$node->BuildFilter("misc_info", $CQPerlExt::CQ_COMP_OP_LIKE, ["%".$queryuser."%"]);
	$node->BuildFilter("login_name", $CQPerlExt::CQ_COMP_OP_LIKE, ["%".$queryuser."%"]);
	my ($resultSet) = $session->BuildResultSet($qryDef);
	# ��ȡ�û���¼

	$resultSet->EnableRecordCount();        
        $resultSet->Execute();
        my($recordCount) = $resultSet->GetRecordCount();

	return -1 if ( $recordCount < 1);
	while ($resultSet->MoveNext() == $CQPerlExt::CQ_SUCCESS) {
		$loginName = $resultSet->GetColumnValue(1);		
		
		}

	return $loginName;
}
