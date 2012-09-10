use strict;
use CQPerlExt;

my ($DATABASE_NAME) = "ali";
my ($DATABASE_SET) = "Alipay";
my ($ADMIN_NAME) = "test";
my ($ADMIN_PWD) = "";
my $session = CQSession::Build();
$session->UserLogon($ADMIN_NAME, $ADMIN_PWD, $DATABASE_NAME, $DATABASE_SET);

my $id = shift(@ARGV);
my $Bug = $session->GetEntity("ȱ��",$id);
my $Bug_headline = $Bug->GetFieldValue("Headline")->GetValue();
my $Bug_info = $Bug->GetFieldValue("����")->GetValue();
print "$Bug_headline\n";
print "$Bug_info\n";
