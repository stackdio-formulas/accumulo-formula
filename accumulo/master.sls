include:
  - accumulo

{%- from 'accumulo/settings.sls' import accumulo with context %}
{%- set hadoop_dfs_cmd = 'hdfs dfs' %}

make-accumulo-dir:
  cmd.run:
    - user: hdfs
    - name: {{ hadoop_dfs_cmd }} -mkdir /accumulo
    - unless: {{ hadoop_dfs_cmd }} -stat /accumulo

set-accumulo-dir:
  cmd.wait:
    - user: hdfs
    - watch:
      - cmd: make-accumulo-dir
    - names:
      - {{ hadoop_dfs_cmd }} -chmod 700 /accumulo
      - {{ hadoop_dfs_cmd }} -chown accumulo /accumulo

make-user-dir:
  cmd.run:
    - user: hdfs
    - name: {{ hadoop_dfs_cmd }} -mkdir /user
    - unless: {{ hadoop_dfs_cmd }} -stat /user

make-accumulo-user-dir:
  cmd.wait:
    - user: hdfs
    - name: {{ hadoop_dfs_cmd }} -mkdir /user/accumulo
    - unless: {{ hadoop_dfs_cmd }} -stat /user/accumulo
    - watch:
      - cmd: make-user-dir

set-accumulo-user-dir:
  cmd.wait:
    - user: hdfs
    - watch:
      - cmd: make-accumulo-user-dir
    - names:
      - {{ hadoop_dfs_cmd }} -chmod 700 /user/accumulo
      - {{ hadoop_dfs_cmd }} -chown accumulo /user/accumulo

check-zookeeper:
  cmd.run:
    - name: {{ accumulo.zookeeper_prefix }}/bin/zkCli.sh ls / | tail -1 > /tmp/acc.status

init-accumulo:
  cmd.run:
    - user: accumulo
    - name: {{accumulo.prefix}}/bin/accumulo init --instance-name {{ accumulo.instance_name }} --password {{ accumulo.secret }} > /var/log/accumulo/accumulo-init.log
    - unless: grep -i accumulo /tmp/acc.status

start-all:
  cmd.run:
    - user: accumulo
    - name: {{accumulo.prefix}}/bin/start-here.sh
