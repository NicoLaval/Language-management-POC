(function() {
    'use strict';
    
    const versions = ['latest', 'v2.2', 'v2.1'];
    const currentPath = window.location.pathname;
    const versionMatch = currentPath.match(/\/(v\d+\.\d+|latest)\//);
    const currentVersion = versionMatch ? versionMatch[1] : 'latest';
    
    function createVersionSelector() {
        if (document.getElementById('version-selector')) {
            return;
        }
        
        const selector = document.createElement('select');
        selector.id = 'version-selector';
        selector.style.cssText = 'margin: 10px; padding: 5px; border-radius: 4px; border: 1px solid #ccc; background: white;';
        selector.title = 'Select version';
        
        versions.forEach(version => {
            const option = document.createElement('option');
            option.value = version;
            option.textContent = version === 'latest' ? 'Latest (v2.2)' : version;
            if (version === currentVersion || (version === 'latest' && currentVersion === 'v2.2')) {
                option.selected = true;
            }
            selector.appendChild(option);
        });
        
        selector.addEventListener('change', function() {
            const selectedVersion = this.value;
            let newPath;
            if (versionMatch) {
                newPath = currentPath.replace(/\/(v\d+\.\d+|latest)\//, `/${selectedVersion}/`);
            } else {
                newPath = `/${selectedVersion}/index.html`;
            }
            window.location.href = newPath;
        });
        
        const navSearch = document.querySelector('.wy-side-nav-search');
        if (navSearch) {
            const wrapper = document.createElement('div');
            wrapper.style.cssText = 'padding: 10px; text-align: center;';
            wrapper.appendChild(selector);
            navSearch.appendChild(wrapper);
        } else {
            const header = document.querySelector('header') || document.querySelector('.header');
            if (header) {
                header.appendChild(selector);
            } else {
                const wrapper = document.createElement('div');
                wrapper.style.cssText = 'position: fixed; top: 10px; right: 10px; z-index: 1000; background: white; padding: 10px; border: 1px solid #ccc; border-radius: 4px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);';
                wrapper.appendChild(document.createTextNode('Version: '));
                wrapper.appendChild(selector);
                document.body.insertBefore(wrapper, document.body.firstChild);
            }
        }
    }
    
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', createVersionSelector);
    } else {
        createVersionSelector();
    }
})();

