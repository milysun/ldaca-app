# BinderHub configuration to bypass Jupyter and serve LDaCA directly
c = get_config()

# Configure the server to proxy directly to our application
c.ServerApp.port = 8888
c.ServerApp.ip = '0.0.0.0'
c.ServerApp.allow_origin = '*'
c.ServerApp.disable_check_xsrf = True

# Configure jupyter-server-proxy to redirect to our app
c.ServerProxy.servers = {
    'ldaca': {
        'command': ['/usr/local/bin/start-ldaca.sh'],
        'port': 8080,
        'timeout': 60,
        'new_browser_tab': False,
        'launcher_entry': {
            'title': 'LDaCA Web Application',
            'icon_path': '/usr/local/share/jupyter/kernels/ldaca.png'
        }
    }
}

# Make LDaCA the default landing page
c.ServerApp.default_url = '/proxy/8080/'
