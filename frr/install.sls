{%- from "frr/map.jinja" import map with context %}

{%- if map.package_url and map.package_hash %}
{%-   set use_repo = False %}
{%- else %}
{%-   set use_repo = True %}
{%- endif %}

{%- set use_custom_repo = map.custom_repo_rpm %}

{%- if use_custom_repo %}
frr_custom_repo:
  pkg.installed:
    - sources:
        - {{ map.custom_repo_name }}: {{ map.custom_repo_rpm }}
    - require_in:
      - pkg: frr_package
{%- endif %}

{%- if not use_repo %}
# Cache the file in order to verify its integrity:
frr_package_cached:
  file.cached:
    - name: {{ map.package_url }}
    - source_hash: {{ map.package_hash }}
{%- endif %}

frr_package:
  pkg.{% if map.package_auto_upgrade and not map.package_url %}latest{% else %}installed{% endif %}:
{%- if use_repo %}
    - name: {{ map.package }}
{%- else %}
    - sources:
      - {{ map.package }}: {{ map.package_url }}
{%- endif %}

frr_logdir:
  file.directory:
    - name: {{ map.log_dir }}
    - user: {{ map.user }}
    - group: {{ map.vtygroup }}
    - mode: '0750'
    - require:
      - pkg: frr_package

frr_confdir:
  file.directory:
    - name: {{ map.conf_dir }}
    - user: root
    - group: {{ map.group }}
    - mode: '0750'
    - require:
      - pkg: frr_package

frr_rundir:
  file.directory:
    - name: {{ map.run_dir }}
    - user: {{ map.user }}
    - group: {{ map.group }}
    - mode: '0750'
    - require:
      - pkg: frr_package
