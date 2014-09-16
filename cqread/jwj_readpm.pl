##########################################################
# 执行：cqperl jwj_readpm.pl 赵翔[pm姓名，旺旺也可]
# cqperl jwj_readpm.pl ali00009837[项目ID]
use CQPerlExt;

my ($DATABASE_NAME) = "bugs";
my ($DATABASE_SET) = "Imbugs";
my ($ADMIN_NAME) = "test";
my ($ADMIN_PWD) = "";

# 输入值
chomp(my $input = $ARGV[0]);
# 返回值
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
# 获取项目信息
# 输入：PM姓名
# 输出：ID:HEADLINE，ID:HEADLINE
# 如果没有查询到，返回－1
sub getProjects{
		my ($pmFullName) = @_;

		my $pm = queryUser($pmFullName);
		
		my  ($qryDef) = $session->BuildQuery("项目");
		my 	$str;	
			
		$qryDef->BuildField("id");
		$qryDef->BuildField("Headline");	
		
		my ($node) = $qryDef->BuildFilterOperator($CQPerlExt::CQ_BOOL_OP_AND);										 
								 
		$node->BuildFilter("项目负责人.login_name", $CQPerlExt::CQ_COMP_OP_EQ, ["$pm"]);		
		$node->BuildFilter("State", $CQPerlExt::CQ_COMP_OP_NOT_IN, ["Closed"]);				
		
		my ($resultSet) = $session->BuildResultSet($qryDef);
        # 获取用户记录
        $resultSet->EnableRecordCount();
        $resultSet->Execute();
        # 写入当前时间
      					
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
# 获取项目开发列表
# 输入：项目ID
# 输出：域名:实名:旺旺，域名:实名:旺旺，
sub getProjectDevs {
		my ($projID) = @_;
		my $str;
		#print "$projID\n";
		my      ($projectObj) = $session->GetEntity("项目",$projID);	
		my	@users = @{$projectObj->GetFieldValue("项目成员")->GetValueAsList()};
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
# 输入：开发loginname
# 输出： 开发:1;不是开发：0
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
		return "$str" if ($group eq "开发");
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
# 用户查询，
# 输入：域名，花名，实名
# 输出：域名

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
	# 获取用户记录

	$resultSet->EnableRecordCount();        
        $resultSet->Execute();
        my($recordCount) = $resultSet->GetRecordCount();

	return -1 if ( $recordCount < 1);
	while ($resultSet->MoveNext() == $CQPerlExt::CQ_SUCCESS) {
		$loginName = $resultSet->GetColumnValue(1);		
		
		}

	return $loginName;
}
