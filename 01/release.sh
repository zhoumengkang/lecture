#!/bin/bash


REPO_URL='git@gitlab.xxx.com:group-name/project-name.git'
CODE_DIR='release-'$USER


# 需要邮件通知的人
MAIL_GROUP=(
    i@zhoumengkang.com
    zhoumengkang@php.net
)

# 预发服务器
PREPARE_SERVERS=(192.168.1.100)
# 正式服务器
PRODUCT_SERVERS=(192.168.1.101 192.168.1.102 192.168.1.103)

set -e

function log()
{
    echo -e -n "\033[01;31m"
    echo $@
    echo -e -n "\033[00m"
}

function release_comfirm()
{
    log "是否需要将" $2 "分支发布到" $1

    read comfirm

    if [ "$comfirm" != "yes" ]; then
        log "发布取消"
        exit 1
    fi
}

function release()
{
    branch=$2

    # to prepare or product servers
    case $1 in
    prepare)
        servers=("${PREPARE_SERVERS[@]}")
        ;;
    product)
        servers=("${PRODUCT_SERVERS[@]}")
        ;;
    *)
        log "参数错误，请输入 prepare 或者 product"
        exit 1
    esac

    cd /tmp

    if [ ! -d $CODE_DIR ]; then
        log '检出代码到 /tmp/' $CODE_DIR '...'
        git clone $REPO_URL $CODE_DIR
    fi

    log '检出分支: ' $branch
    cd $CODE_DIR && git fetch && git checkout $branch -- && git pull --progress --no-stat -v origin $branch && cd -

    log '记录本次提交的版本号，方便回滚使用...'
    cd $CODE_DIR && git show > last_commit && logmsg=`git log -n 1` && cd -

    for server in "${servers[@]}";
    do
        log "发布文件到 $server"
        rsync -avz --links --hard-links --times --delete --recursive \
            --exclude ".git" \
            --exclude ".gitignore" \
            --exclude release.sh \
            --exclude output/ \
            $CODE_DIR/ username@$server:/path/of/code/
    done
    retval=$?
    if [ $retval != 0 ]; then
        log '发布失败 :('
    else
        log '发布完成 :)'
    fi

    if [ $1 == "product" ]; then
        for i in $MAIL_GROUP;do
            echo -e "The project has been pushed to $2 servers.\n---------------------------------------\nLast commit:\n$logmsg\n---------------------------------------\n operate: $USER" |mail -s "on-line notification" $i
        done
    fi
}

if [ $# == 0 ] || [ $# == 1 ]; then
    echo "第一个参数输入预发或者线上 (prepare or product) ，第二个参数输入分支名。"
    exit 1
fi

release_comfirm $1 $2

release $1 $2
