# Bash Script create backup and send copy to AWS EC2.
# Created by P.M.
# Tested 16.06.25.
# Modified 19.06.25.
#--------------------------------------------------

BACKUP_DIR="/home/pavl/backup"
SOURCE_FILE="/home/pavl/scripts"
DEST_FILE="$BACKUP_DIR/script_backups_$(date +%F_%H-%M).tar.gz"

REMOTE_USER="ec2-user"
REMOTE_HOST="your server IP address "
REMOTE_DIR="/home/ec2-user/backup"
SSH_KEY="/home/pavl/.ssh/key.pem"

CHAT_ID="your Telegram chat id"
MESSAGE="[Backup Error] on $(hostname) to $REMOTE_HOST at $(date)"
API_TOKEN=$(cat /home/pavl/.telegram_token)

tar -czf "$DEST_FILE" "$SOURCE_FILE"
echo "Backup created: $DEST_FILE"

find "$BACKUP_DIR" -name "script_backups_*.tar.gz" -mtime +5 -exec rm {} \;

/usr/bin/rsync -avz -e "ssh -i $SSH_KEY" "$DEST_FILE" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR"

if [ $? -eq 0 ]; then
    echo "Backup: $DEST_FILE sent successfully."
else
    echo "Error during backup transfer."
    /usr/bin/curl -s -X POST "https://api.telegram.org/bot$API_TOKEN/sendMessage" \
        -d chat_id="$CHAT_ID" \
        -d text="$MESSAGE" &> /dev/null
fi
