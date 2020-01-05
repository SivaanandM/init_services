# Previous Market day date eg: 20191121
PDATE=$1
# Current market day date eg: 20191122
MDATE=$2

ROOT_DIR=/thevuk/
STREAM_DIR=/thevuk/TickStream/
AGENT_DIR=/thevuk/TickAlgoAgent/
HRHD_DIR=/thevuk/HRHD_Worker/

## Starting Kafka Services

echo "Starting Zookeeper"
bash /kafka/bin/zookeeper-server-start.sh -daemon /kafka/config/zookeeper.properties > /tmp/zookeeper.log
sleep 5
echo "Starting Kafka server"
bash /kafka/bin/kafka-server-start.sh -daemon /kafka/config/server.properties > /tmp/kafka.log
sleep 5
## Creating lisener services
cd $STREAM_DIR
PIPE_LIST=($(echo $(python3 src/main/getpipelist.py) | tr "," "\n"))
cd $ROOT_DIR
## Print the split string
cd $AGENT_DIR
## Creating consumer pipe
for i in "${PIPE_LIST[@]}"
do
    echo "Starting Lisener Service for - "$i
    python3 -u src/main/main.py -t "$i" -md $MDATE -pd $PDATE -s "$i" >> /tmp/$i.log &
    sleep 4
done
## Waiting for all topic to be updated
sleep 5
cd $ROOT_DIR
## Triggering tick streamer
cd $STREAM_DIR
python3 -u src/main/main.py >> /tmp/tickstream.log &
sleep 5
echo "** All Initiation Completed Sucessfully, All the Best -- PUNYA** "
