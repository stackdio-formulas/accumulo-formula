include:
  - accumulo

{%- from 'accumulo/settings.sls' import accumulo with context %}

start-all:
  cmd.run:
    - user: accumulo
    - name: {{accumulo.prefix}}/bin/start-here.sh

