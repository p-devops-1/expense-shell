source common.sh

mysql_root_password=$1
# if password is not provided, then we will exit
if [ -z "${mysql_root_password}" ]; then
  echo input missing
  exit 1
  fi

Print_Task_Heading "Disable Default NodeJS Version Module"
dnf module disable nodejs -y &>>/tmp/expense.log
echo $?

Print_Task_Heading "Enable NodeJS Module for v20"
dnf module enable nodejs:20 -y &>>/tmp/expense.log
echo $?

Print_Task_Heading "Install NodeJS"
dnf install nodejs -y &>>/tmp/expense.log
echo $?

Print_Task_Heading "Adding Application User"
useradd expense &>>/tmp/expense.log
echo $?

Print_Task_Heading "Copy backend service file"
cp backend.service /etc/systemd/system/backend.service &>>/tmp/expense.log
echo $?

Print_Task_Heading "clean the old content"
rm -rf /app &>>/tmp/expense.log
echo $?

Print_Task_Heading "create App directory"
mkdir /app &>>/tmp/expense.log
echo $?

Print_Task_Heading "Download App content"
curl -o /tmp/backend.zip https://expense-artifacts.s3.amazonaws.com/expense-backend-v2.zip &>>/tmp/expense.log
echo $?

Print_Task_Heading "Extract App content"
cd /app &>>/tmp/expense.log
unzip /tmp/backend.zip &>>/tmp/expense.log
echo $?

Print_Task_Heading "Download NodeJS Dependencies"
cd /app &>>/tmp/expense.log
npm install &>>/tmp/expense.log
echo $?

Print_Task_Heading "start Backend Service"
systemctl daemon-reload &>>/tmp/expense.log
systemctl enable backend &>>/tmp/expense.log
systemctl start backend &>>/tmp/expense.log
echo $?

Print_Task_Heading "Install MySQL client"
dnf install mysql -y &>>/tmp/expense.log
echo $?

Print_Task_Heading "Load Schema"
mysql -h 172.31.90.147 -uroot -p${mysql_root_password} < /app/schema/backend.sql &>>/tmp/expense.log
echo $?