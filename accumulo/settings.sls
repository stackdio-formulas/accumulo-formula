{%- set default_uid = '6040' %}
{%- set userhome = '/home/accumulo' %}
{%- set uid = salt['pillar.get']('accumulo:uid', default_uid) %}
# the version and source can either come out of a grain, the pillar or end up the default (currently 1.5.0 and the apache backup mirror)
{%- set pillar_version     = salt['pillar.get']('accumulo:version', '1.5.0') %}
{%- set version      = salt['grains.get']('accumulo_version', pillar_version) %}
{%- set default_url  = 'http://www.us.apache.org/dist/accumulo/' + version + '/accumulo-' + version + '-bin.tar.gz' %}
{%- set pillar_source      = salt['pillar.get']('accumulo:source', default_url) %}
{%- set source_url   = salt['grains.get']('accumulo_source', pillar_source) %}
{%- set version_name = 'accumulo-' + version %}
{%- set prefix = salt['pillar.get']('accumulo:prefix', '/usr/lib/accumulo') %}
{%- set instance_name = salt['pillar.get']('accumulo:config:instance_name', 'accumulo') %}
{%- set secret = salt['pillar.get']('accumulo:secret', 'secret') %}
{%- set alt_config = salt['pillar.get']('accumulo:config:directory', '/etc/accumulo/conf') %}
{%- set real_config = alt_config + '-' + version %}
{%- set alt_home  = salt['pillar.get']('accumulo:prefix', '/usr/lib/accumulo') %}
{%- set real_home = alt_home + '-' + version %}
{%- set real_config_src = real_home + '/conf' %}
{%- set real_config_dist = alt_config + '.dist' %}
{%- set java_home = salt['pillar.get']('accumulo:config:accumulo-env:java_home', '/usr/lib/java') %}

{%- set hadoop_prefix  = salt['pillar.get']('accumulo:config:hadoop:prefix', '/usr/lib/hadoop') %}
{%- set hadoop_config  = salt['pillar.get']('accumulo:config:hadoop:config', '/etc/hadoop/conf') %}
{%- set hadoop_major_version = salt['pillar.get']('accumulo:config:hadoop:major_version', '2') %}
{%- set hadoop_classpaths = salt['pillar.get']('accumulo:config:hadoop:classpaths', []) %}
{%- set zookeeper_prefix  = salt['pillar.get']('accumulo:zookeeper:prefix', '/usr/lib/zookeeper') %}
{%- set accumulo_default_loglevel = 'WARN' %}
{%- set accumulo_loglevels = ['DEBUG', 'INFO', 'WARN', 'ERROR'] %}
{%- set accumulo_ll = salt['pillar.get']('accumulo:config:loglevel', accumulo_default_loglevel) %}
{%- if accumulo_ll in accumulo_loglevels %}
{%- set accumulo_loglevel = accumulo_ll %}
{%- else %}
{%- set accumulo_loglevel = accumulo_default_loglevel %}
{%- endif %}
{%- set accumulo_default_profile = salt['grains.get']('accumulo_default_profile', '512MB') %}
{%- set accumulo_profile = salt['grains.get']('accumulo_profile', accumulo_default_profile) %}
{%- set accumulo_profile_dict = salt['pillar.get']('accumulo:config:accumulo-site-profiles:' + accumulo_profile, None) %}

# TODO:
{%- set namenode_host = salt['publish.publish']('G@stack_id:' ~ grains.stack_id ~ ' and G@roles:cdh4.hadoop.namenode', 'grains.get', 'fqdn', 'compound').values()|first() %}
{%- set zookeeper_host = namenode_host %}
{%- set accumulo_master = salt['publish.publish']('G@stack_id:' ~ grains.stack_id ~ ' and G@roles:accumulo.server', 'grains.get', 'fqdn', 'compound').values()|first() %}
{%- set accumulo_slaves = salt['publish.publish']('G@stack_id:' ~ grains.stack_id ~ ' and G@roles:accumulo.slave', 'grains.get', 'fqdn', 'compound').values() %}

{%- set accumulo = {} %}
{%- do accumulo.update( { 'uid': uid,
                          'version' : version,
                          'version_name': version_name,
                          'userhome' : userhome,
                          'sources': None,
                          'source_url': source_url,
                          'prefix' : prefix,
                          'instance_name': instance_name,
                          'secret': secret,
                          'alt_config' : alt_config,
                          'real_config' : real_config,
                          'alt_home' : alt_home,
                          'real_home' : real_home,
                          'real_config_src' : real_config_src,
                          'real_config_dist' : real_config_dist,
                          'java_home' : java_home,
                          'hadoop_prefix': hadoop_prefix,
                          'hadoop_config': hadoop_config,
                          'hadoop_major_version': hadoop_major_version,
                          'hadoop_classpaths': hadoop_classpaths,
                          'zookeeper_prefix' : zookeeper_prefix,
                          'namenode_host' : namenode_host,
                          'zookeeper_host' : zookeeper_host,
                          'accumulo_master' : accumulo_master,
                          'accumulo_slaves' : accumulo_slaves,
                          'accumulo_loglevel' : accumulo_loglevel,
                          'accumulo_default_profile' : accumulo_default_profile,
                          'accumulo_profile' : accumulo_profile
                        }) %}
