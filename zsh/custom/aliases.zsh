alias sshrhel='ssh phaffley@et.local@etinhaffley01.et.local'
#alias sshdev='ssh phaffley@et.local@etintacos01.et.local'
#alias sshdev='ssh phaffley@et.local@etintacos01.et.local'
alias sshetssprod='ssh phaffley@et.local@tacos-scheduler.internal.salesforce.com'
alias sshetssqa='ssh phaffley@et.local@tacos-scheduler-staging.internal.salesforce.com'
alias sshetprod='ssh phaffley@et.local@tacos.internal.salesforce.com'
alias sshetqa='ssh phaffley@et.local@tacos-staging.internal.salesforce.com'
alias sshetdev='ssh phaffley@et.local@tacos-dev.internal.salesforce.com'
alias sshlocal='ssh -p2222 phaffley@127.0.0.1'
alias tjq='tail -f application.log | jq --unbuffered .'
alias tldev='sshdev tail -f /opt/mcat/TestAutomationConfigOnlineService/log/application.log | jq --unbuffered .'
alias tlqa='sshqa tail -f /opt/mcat/TestAutomationConfigOnlineService/log/application.log | jq --unbuffered .'
alias tlprod='sshprod tail -f /opt/mcat/TestAutomationConfigOnlineService/log/application.log | jq --unbuffered .'
# alias tmux='TERM=screen-256color-bce tmux'
alias sshssprod='ssh centos@10.27.0.80'
alias sshssqa='ssh centos@10.27.0.73'
alias sshssdev='ssh centos@10.27.0.207'
alias sshprod='ssh centos@10.27.0.97'
alias sshqa='ssh centos@10.27.0.226'
alias sshdev='ssh centos@10.27.0.101'
alias sshsplunk='ssh ec2-user@10.27.0.142'
alias ssha='ssh centos@10.27.0.175'
alias ssh1a='ssh ssh.us-east-1a.test-exacttarget.com'
alias ssh1c='ssh ssh.us-east-1c.test-exacttarget.com'
alias sshw1='ssh ssh.q4.test-exacttarget.com'
alias sshaw1='ssh 10.0.91.5'
alias rsyncaw1='rsync -avh --delete --exclude-from=.gitignore --exclude=.vcode . 10.0.91.5:ProvisioningService'
alias sshtca='ssh ec2-user@10.27.0.30'
alias rgrep='grep -R -n'
alias mc-test='node --max-old-space-size=10240 node_modules/.bin/mc-test'