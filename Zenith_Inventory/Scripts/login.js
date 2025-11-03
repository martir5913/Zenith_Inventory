document.getElementById('togglePassword').addEventListener('click', function () {
    const passwordInput = document.getElementById('password');
    const type = passwordInput.getAttribute('type') === 'password' ? 'text' : 'password';
    passwordInput.setAttribute('type', type);

    // Cambiar el ícono
    const svg = this.querySelector('svg');
    if (type === 'password') {
        svg.innerHTML = '<path d="M1 12C1 12 5 4 12 4C19 4 23 12 23 12C23 12 19 20 12 20C5 20 1 12 1 12Z" stroke="#fff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/><circle cx="12" cy="12" r="3" stroke="#fff" stroke-width="2"/>';
    } else {
        svg.innerHTML = '<path d="M17.94 17.94A10.07 10.07 0 0 1 12 20C5 20 1 12 1 12C1 12 2.64 8.53 6.06 6.06M9.9 4.24A9.12 9.12 0 0 1 12 4C19 4 23 12 23 12C23 12 21.36 15.47 17.94 17.94M14.12 14.12A3 3 0 1 1 9.88 9.88M1 1L23 23" stroke="#fff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>';
    }
});

document.getElementById('frmLogin').addEventListener('submit', function (e) {
    const username = document.getElementById('txtUser').value.trim();
    const password = document.getElementById('password').value;
    const loginButton = document.getElementById('btnIngresar');

    if (!username || !password) {
        e.preventDefault();
        alert('Por favor complete todos los campos');
        return;
    }

    // Mostrar loading
    loginButton.innerHTML = '<i class="bi bi-arrow-clockwise spin"></i> Iniciando sesión...';
    loginButton.disabled = true;
});

// Manejo de formulario con Enter
document.addEventListener('keypress', function (e) {
    if (e.key === 'Enter') {
        const activeElement = document.activeElement;
        if (activeElement.tagName === 'INPUT') {
            document.getElementById('frmLogin').submit();
        }
    }
});