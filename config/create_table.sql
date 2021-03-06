set character_set_server = utf8;
set character_set_database = utf8;
create table if not exists workflow(
    name varchar(128) primary key  not null,
    creator varchar(128),
    dir varchar(128),
    description varchar(1024),
    mail_level JSON,
    mail_receivers JSON,
    instance_limit int,
    params JSON comment '参数名称集合,例: [sdate,otype]',
    xml_str text comment 'xml的内容',
    create_time datetime,
    last_update_time datetime,
    
    coor_enable int(1) comment '调度器是否可用',
    coor_param JSON comment '调度器参数列表,例：[{"name":"stadate","value":"{time.yestoday|yyyy-mm-dd}"}]',
    coor_cron varchar(128) comment '前置触发时间',
    coor_next_cron_time datetime comment '下次时间触发',
    coor_depends JSON comment '前置依赖工作流集合',
    coor_stime datetime comment '调度器起始时间',
    coor_etime datetime comment '调度器结束时间'
);

create table if not exists node (
    name varchar(128) not null,
    is_action int(1) comment '是否为action节点',
    type varchar(100) comment '节点类型',
    content JSON comment '节点存放内容',
    workflow_name varchar(128) comment '外键->workflow_info:name',
    description varchar(1024)
);    
create table if not exists workflow_instance(
    id varchar(8) primary key not null,
    name varchar(128) not null,
    creator varchar(128),
    dir varchar(128),
    param JSON,
    status int(1) comment "0:就绪，1:运行中，2:挂起，3:执行成功，4:执行失败，5:杀死",
    description varchar(1024),
    mail_level JSON,
    mail_receivers JSON,
    instance_limit int,
    stime datetime,
    etime datetime,
    create_time datetime,
    last_update_time datetime,
    xml_str text comment 'xml的内容'
);

create table if not exists node_instance (
    workflow_instance_id varchar(8) not null,
    name varchar(200) not null,
    is_action int(1) comment '是否为action节点',
    type varchar(100) comment '节点类型',
    content JSON comment '节点存放内容',
    description varchar(1024),
    status int(1) comment "0:就绪，1:运行中，2:挂起，3:执行成功，4:执行失败，5:杀死",
    stime datetime,
    etime datetime,
    msg varchar(1024),
    index(workflow_instance_id)
);

create table if not exists log_record (
    id int(10) primary key auto_increment,
    level varchar(10),
    stime datetime(3),
    ctype varchar(60),
    sid varchar(20),
    name varchar(60),
    content varchar(1024)
);

create table if not exists directory(
    id int(4) AUTO_INCREMENT primary key,
    pid int(4) not null,
    is_leaf int(1) not null comment '1: 叶子节点，0: 目录',
    name varchar(128) not null,
    description varchar(1024)
);
create table if not exists data_monitor(
    time_mark varchar(64) not null comment '时间字段，格式自定义',
    category varchar(64) not null comment '数据源分类',
    source_name varchar(64) not null comment '数据源名称',
    num double not null comment '监测值',
    min double comment '下限',
    max double comment '上限',
    workflow_instance_id varchar(8) not null, 
    remark varchar(1024) comment '备注'
);
delete from node_instance where workflow_instance_id in (select id from workflow_instance where status = 1);
delete from workflow_instance where status = 1
