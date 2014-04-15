{%- if grains['os_family'] in ['RedHat'] %}
redhat-lsb-core:
  pkg.installed
{% endif %}

{%- from 'accumulo/settings.sls' import accumulo with context %}

accumulo:
  group.present:
    - gid: {{ accumulo.uid }}
  user.present:
    - uid: {{ accumulo.uid }}
    - gid: {{ accumulo.uid }}
    - shell: /bin/bash
    - home: {{ accumulo.userhome }}
    - groups: ['hadoop']
    - require:
      #- group: hadoop
      - group: accumulo
  file.directory:
    - user: accumulo
    - group: accumulo
    - names:
      - /var/log/accumulo
      - /var/run/accumulo
      - /var/lib/accumulo

{{ accumulo.userhome }}/.ssh:
  file.directory:
    - user: accumulo
    - group: accumulo
    - mode: 744
    - require:
      - user: accumulo
      - group: accumulo

{%- if accumulo.accumulo_private_key and accumulo.accumulo_public_key %}
accumulo_private_key:
  file.managed:
    - name: {{ accumulo.userhome }}/.ssh/id_dsa
    - user: accumulo
    - group: accumulo
    - mode: 600
    - contents: |
        {{ accumulo.accumulo_private_key | indent(8) }}
    - require:
      - file: {{ accumulo.userhome }}/.ssh

accumulo_public_key:
  file.managed:
    - name: {{ accumulo.userhome }}/.ssh/id_dsa.pub
    - user: accumulo
    - group: accumulo
    - mode: 644
    - contents: {{ accumulo.accumulo_public_key }}
    - require:
      - file: accumulo_private_key

ssh_dss_accumulo:
  ssh_auth.present:
    - user: accumulo
    - name: {{ accumulo.accumulo_public_key }}
    - require:
      - file: accumulo_private_key
{%- endif %}

{{ accumulo.userhome }}/.ssh/config:
  file.managed:
    - source: salt://accumulo/conf/ssh/ssh_config
    - user: accumulo
    - group: accumulo
    - mode: 644
    - require:
      - file: {{ accumulo.userhome }}/.ssh

{{ accumulo.userhome }}/.bashrc:
  file.append:
    - text:
      - export PATH=$PATH:/usr/lib/hadoop/bin:/usr/lib/hadoop/sbin:/usr/lib/accumulo/bin

install-accumulo-dist:
  cmd.run:
    - name: curl '{{ accumulo.source_url }}' | tar xz
    - user: root
    - group: root
    - cwd: /usr/lib
    - unless: test -d {{ accumulo.alt_home }}

accumulo-home-link:
  alternatives.install:
    - link: {{ accumulo.alt_home }}
    - path: {{ accumulo.real_home }}
    - priority: 30
    - require:
      - cmd: install-accumulo-dist

{{ accumulo.real_home }}:
  file.directory:
    - user: root
    - group: root
    - recurse:
      - user
      - group

/etc/accumulo:
  file.directory:
    - owner: root
    - group: root
    - mode: 755

{{ accumulo.real_config }}:
  file.recurse:
    - source: salt://accumulo/conf
    - template: jinja
    - file_mode: 644
    - user: root
    - group: root
    - context:
      prefix: {{ accumulo.prefix }}
      java_home: {{ accumulo.java_home }}
      hadoop_prefix: {{ accumulo.hadoop_prefix }}
      hadoop_config: {{ accumulo.hadoop_config }}
      hadoop_classpaths: {{ accumulo.hadoop_classpaths }}
      alt_config: {{ accumulo.alt_config }}
      zookeeper_prefix: {{ accumulo.zookeeper_prefix }}
      accumulo_logs: '/var/log/accumulo'
      namenode_host: {{ accumulo.namenode_host }}
      zookeeper_host: {{ accumulo.zookeeper_host }}
      hadoop_major: {{ accumulo.hadoop_major_version }}
      accumulo_master: {{ accumulo.accumulo_master }}
      accumulo_slaves: {{ accumulo.accumulo_slaves }}
      accumulo_default_profile: {{ accumulo.accumulo_default_profile }}
      accumulo_profile: {{ accumulo.accumulo_profile }}
      accumulo_loglevel: {{ accumulo.accumulo_loglevel }}
      secret: {{ accumulo.secret }}

move-accumulo-dist-conf:
  cmd.run:
    - name: mv  {{ accumulo.real_config_src }} {{ accumulo.real_config_dist }}
    - unless: test -L {{ accumulo.real_config_src }}
    - onlyif: test -d {{ accumulo.real_config_src }}
    - require:
      - file: {{ accumulo.real_home }}
      - file: /etc/accumulo

{{ accumulo.real_config_src }}:
  file.symlink:
    - target: {{ accumulo.alt_config }}
    - require:
      - cmd: move-accumulo-dist-conf

accumulo-conf-link:
  alternatives.install:
    - link: {{ accumulo.alt_config }}
    - path: {{ accumulo.real_config }}
    - priority: 30
    - require:
      - file: {{ accumulo.real_config }}
