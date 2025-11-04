// ========================================
// ZENITH INVENTORY - LAYOUT JAVASCRIPT
// Handles sidebar, mobile menu, and interactions
// Updated: Single submenu open at a time
// ========================================

(function () {
    'use strict';

    // DOM Elements
    const sidebar = document.getElementById('sidebar');
    const sidebarToggle = document.getElementById('sidebarToggle');
 const menuMobile = document.getElementById('menuMobile');
    const mainContent = document.getElementById('mainContent');
    const navLinks = document.querySelectorAll('.nav-link');

    // ========================================
    // SIDEBAR TOGGLE (Desktop)
    // ========================================
 if (sidebarToggle) {
        sidebarToggle.addEventListener('click', function () {
            sidebar.classList.toggle('collapsed');
            
   // Save state to localStorage
   const isCollapsed = sidebar.classList.contains('collapsed');
  localStorage.setItem('sidebarCollapsed', isCollapsed);
    });
    }

    // ========================================
    // MOBILE MENU TOGGLE
    // ========================================
  if (menuMobile) {
   menuMobile.addEventListener('click', function () {
       sidebar.classList.toggle('show');
            
 // Add overlay
        if (sidebar.classList.contains('show')) {
          createOverlay();
            } else {
     removeOverlay();
  }
        });
    }

// ========================================
    // CREATE OVERLAY FOR MOBILE
  // ========================================
    function createOverlay() {
        const overlay = document.createElement('div');
        overlay.className = 'sidebar-overlay';
  overlay.style.cssText = `
   position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
 background: rgba(0, 0, 0, 0.5);
    z-index: 999;
            animation: fadeIn 0.3s ease;
 `;
    
        overlay.addEventListener('click', function () {
 sidebar.classList.remove('show');
            removeOverlay();
   });
    
     document.body.appendChild(overlay);
    }

    // ========================================
    // REMOVE OVERLAY
    // ========================================
    function removeOverlay() {
        const overlay = document.querySelector('.sidebar-overlay');
   if (overlay) {
overlay.remove();
    }
    }

    // ========================================
    // RESTORE SIDEBAR STATE FROM LOCALSTORAGE
    // ========================================
    function restoreSidebarState() {
        const isCollapsed = localStorage.getItem('sidebarCollapsed') === 'true';
      if (isCollapsed && window.innerWidth > 768) {
     sidebar.classList.add('collapsed');
     }
    }

    // ========================================
    // SET ACTIVE NAV LINK - IMPROVED VERSION
    // ========================================
  function setActiveNavLink() {
  // Try to get context from server first (most reliable)
        let currentController = 'Home';
   let currentAction = 'Index';

        if (window.zenithContext) {
  currentController = window.zenithContext.controller || 'Home';
   currentAction = window.zenithContext.action || 'Index';
        } else {
      // Fallback to URL parsing
       const pathParts = window.location.pathname.split('/').filter(p => p);
       currentController = pathParts[0] || 'Home';
       currentAction = pathParts[1] || 'Index';
 }

  console.log('Current Location:', { controller: currentController, action: currentAction });

        // Remove all active classes first
  navLinks.forEach(link => link.classList.remove('active'));
        document.querySelectorAll('.submenu-link').forEach(link => link.classList.remove('active'));
   document.querySelectorAll('.submenu').forEach(submenu => {
 submenu.classList.remove('show');
  const parentLink = submenu.previousElementSibling;
  if (parentLink) {
  parentLink.setAttribute('aria-expanded', 'false');
            }
   });

     // Find matching links
  let matchFound = false;

        // First, check submenu links for exact match
        document.querySelectorAll('.submenu-link').forEach(link => {
      const linkController = link.getAttribute('data-controller');
      const linkAction = link.getAttribute('data-action');

if (linkController && linkAction) {
       const controllerMatch = linkController.toLowerCase() === currentController.toLowerCase();
  const actionMatch = linkAction.toLowerCase() === currentAction.toLowerCase();

   if (controllerMatch && actionMatch) {
    // Mark submenu link as active
   link.classList.add('active');
    matchFound = true;

    // Expand parent submenu
    const submenu = link.closest('.submenu');
          if (submenu) {
  submenu.classList.add('show');
   
     // Mark parent nav-link as active
     const parentLink = submenu.previousElementSibling;
       if (parentLink) {
    parentLink.classList.add('active');
       parentLink.setAttribute('aria-expanded', 'true');
         }
       }

        console.log('Submenu link activated:', link.textContent.trim());
         }
     }
        });

  // If no submenu match, check main nav links
   if (!matchFound) {
  navLinks.forEach(link => {
   const linkController = link.getAttribute('data-controller');
    const linkAction = link.getAttribute('data-action');

    // Check if it's a toggle link (has submenu)
const isToggle = link.getAttribute('data-bs-toggle') === 'collapse';
       
   if (!isToggle && linkController) {
    const controllerMatch = linkController.toLowerCase() === currentController.toLowerCase();
 const actionMatch = !linkAction || linkAction.toLowerCase() === currentAction.toLowerCase();

        if (controllerMatch && actionMatch) {
         link.classList.add('active');
      matchFound = true;
   console.log('Main link activated:', link.textContent.trim());
    }
 }
   
   // Check if current controller matches a submenu parent
   if (isToggle && linkController) {
 const controllers = linkController.split(',').map(c => c.trim().toLowerCase());
if (controllers.includes(currentController.toLowerCase())) {
  link.classList.add('active');
       
  // Expand the submenu
    const submenuId = link.getAttribute('href');
     if (submenuId) {
   const submenu = document.querySelector(submenuId);
     if (submenu) {
        submenu.classList.add('show');
 link.setAttribute('aria-expanded', 'true');
  console.log('Parent submenu activated:', link.textContent.trim());
    }
 }
         matchFound = true;
  }
    }
    });
        }

        // Fallback: if still no match and we're on a controller page
if (!matchFound && currentController) {
     console.log('No exact match found, looking for controller-only match');
       
   // Try to find any link matching the controller
   navLinks.forEach(link => {
    const linkController = link.getAttribute('data-controller');
if (linkController && linkController.toLowerCase() === currentController.toLowerCase()) {
        link.classList.add('active');
        
       // If it's a submenu parent, expand it
  const isToggle = link.getAttribute('data-bs-toggle') === 'collapse';
        if (isToggle) {
  const submenuId = link.getAttribute('href');
            if (submenuId) {
   const submenu = document.querySelector(submenuId);
 if (submenu) {
          submenu.classList.add('show');
    link.setAttribute('aria-expanded', 'true');
   }
       }
    }
       console.log('Controller-only match activated:', link.textContent.trim());
        }
     });
        }
    }

    // ========================================
    // HANDLE SUBMENU CLICKS - Only one open at a time with smooth transitions
    // ========================================
    navLinks.forEach(link => {
        link.addEventListener('click', function (e) {
         const targetSubmenu = link.getAttribute('data-bs-toggle');
       const submenuId = link.getAttribute('href');

    // If it's a submenu toggle
            if (targetSubmenu === 'collapse' && submenuId) {
        e.preventDefault();
      
// Get the submenu element
       const submenu = document.querySelector(submenuId);
              
    if (submenu) {
// Check if this submenu is currently open
       const isCurrentlyOpen = submenu.classList.contains('show');

       // Get all submenus
     const allSubmenus = document.querySelectorAll('.submenu');
         
          // If we're opening a different submenu, close others with animation
        if (!isCurrentlyOpen) {
            let hasOpenSubmenu = false;
          
   allSubmenus.forEach(menu => {
      if (menu !== submenu && menu.classList.contains('show')) {
       hasOpenSubmenu = true;
                // Remove show class to trigger close animation
        menu.classList.remove('show');
            
            // Update parent link aria-expanded
      const parentLink = menu.previousElementSibling;
     if (parentLink) {
  parentLink.setAttribute('aria-expanded', 'false');
     }
         }
             });
       
    // If there was an open submenu, wait for it to close before opening new one
                if (hasOpenSubmenu) {
setTimeout(() => {
            submenu.classList.add('show');
     link.setAttribute('aria-expanded', 'true');
          }, 150); // Small delay for smooth transition
                  } else {
    // No open submenu, open immediately
             submenu.classList.add('show');
       link.setAttribute('aria-expanded', 'true');
         }
             } else {
    // Closing the current submenu
      submenu.classList.remove('show');
        link.setAttribute('aria-expanded', 'false');
         }
    }

      // Close sidebar on mobile after selection
   if (window.innerWidth <= 768) {
 setTimeout(() => {
     sidebar.classList.remove('show');
      removeOverlay();
          }, 300);
        }
            } else {
      // Regular link - close all open submenus and mobile menu
                // Close all open submenus
                const allSubmenus = document.querySelectorAll('.submenu');
                allSubmenus.forEach(menu => {
                    if (menu.classList.contains('show')) {
                        menu.classList.remove('show');
                        const parentLink = menu.previousElementSibling;
                        if (parentLink) {
                            parentLink.setAttribute('aria-expanded', 'false');
                        }
                    }
                });

         if (window.innerWidth <= 768) {
     sidebar.classList.remove('show');
        removeOverlay();
     }
      }
        });
    });

    // ========================================
    // HANDLE WINDOW RESIZE
    // ========================================
    let resizeTimer;
    window.addEventListener('resize', function () {
        clearTimeout(resizeTimer);
        resizeTimer = setTimeout(function () {
          // Remove mobile menu show class on desktop
          if (window.innerWidth > 768) {
         sidebar.classList.remove('show');
          removeOverlay();
       
      // Restore collapsed state
      const isCollapsed = localStorage.getItem('sidebarCollapsed') === 'true';
     if (isCollapsed) {
         sidebar.classList.add('collapsed');
}
            } else {
    // On mobile, remove collapsed class
         sidebar.classList.remove('collapsed');
            }
        }, 250);
    });

    // ========================================
    // SMOOTH SCROLL TO TOP
 // ========================================
    function createScrollTopButton() {
   const scrollBtn = document.createElement('button');
        scrollBtn.className = 'scroll-to-top';
        scrollBtn.innerHTML = '<i class="bi bi-arrow-up"></i>';
        scrollBtn.style.cssText = `
       position: fixed;
    bottom: 30px;
            right: 30px;
      width: 50px;
      height: 50px;
      background: linear-gradient(135deg, #0066CC, #00C8FF);
            color: white;
        border: none;
     border-radius: 50%;
    cursor: pointer;
            box-shadow: 0 4px 12px rgba(0, 102, 204, 0.4);
         display: none;
    align-items: center;
justify-content: center;
        font-size: 20px;
            z-index: 998;
            transition: all 0.3s ease;
        `;
        
        scrollBtn.addEventListener('click', function () {
         window.scrollTo({
      top: 0,
         behavior: 'smooth'
          });
     });
        
 // Show/hide based on scroll position
        window.addEventListener('scroll', function () {
            if (window.pageYOffset > 300) {
             scrollBtn.style.display = 'flex';
            } else {
            scrollBtn.style.display = 'none';
        }
     });
        
        document.body.appendChild(scrollBtn);
    }

    // ========================================
    // TOOLTIPS INITIALIZATION (Bootstrap)
    // ========================================
    function initTooltips() {
        const tooltipTriggerList = [].slice.call(
     document.querySelectorAll('[data-bs-toggle="tooltip"]')
        );
        tooltipTriggerList.map(function (tooltipTriggerEl) {
 return new bootstrap.Tooltip(tooltipTriggerEl);
  });
    }

    // ========================================
    // NOTIFICATION BADGE ANIMATION
    // ========================================
    function animateNotificationBadge() {
        const badge = document.querySelector('.badge-notification');
  if (badge) {
            setInterval(() => {
       badge.style.animation = 'none';
     setTimeout(() => {
   badge.style.animation = 'pulse 1s ease';
      }, 10);
          }, 5000);
        }
    }

    // Add pulse animation to CSS dynamically
    const style = document.createElement('style');
    style.textContent = `
        @keyframes pulse {
 0%, 100% { transform: scale(1); }
       50% { transform: scale(1.1); }
        }
    `;
    document.head.appendChild(style);

    // ========================================
    // AUTO-HIDE ALERTS/MESSAGES
    // ========================================
    function autoHideAlerts() {
      const alerts = document.querySelectorAll('.alert');
    alerts.forEach(alert => {
     setTimeout(() => {
          const bsAlert = new bootstrap.Alert(alert);
        bsAlert.close();
 }, 5000);
        });
    }

    // ========================================
    // KEYBOARD SHORTCUTS
    // ========================================
    function setupKeyboardShortcuts() {
 document.addEventListener('keydown', function (e) {
      // Ctrl/Cmd + B - Toggle Sidebar
            if ((e.ctrlKey || e.metaKey) && e.key === 'b') {
       e.preventDefault();
                if (sidebarToggle) {
    sidebarToggle.click();
      }
}
            
  // Escape - Close mobile menu
            if (e.key === 'Escape') {
          if (sidebar.classList.contains('show')) {
        sidebar.classList.remove('show');
  removeOverlay();
                }
            }
  });
    }

 // ========================================
    // INITIALIZE ON DOM READY
    // ========================================
 document.addEventListener('DOMContentLoaded', function () {
        restoreSidebarState();
     setActiveNavLink();
        createScrollTopButton();
 initTooltips();
     animateNotificationBadge();
        autoHideAlerts();
        setupKeyboardShortcuts();
        
      // Add fade-in animation to content
        const content = document.querySelector('.content');
        if (content) {
       content.classList.add('fade-in');
        }
    });

    // ========================================
    // EXPORT FOR GLOBAL ACCESS (if needed)
    // ========================================
    window.ZenithLayout = {
        toggleSidebar: function () {
    if (sidebarToggle) sidebarToggle.click();
     },
        closeMobileMenu: function () {
  sidebar.classList.remove('show');
     removeOverlay();
        }
    };

})();
