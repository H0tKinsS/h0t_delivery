$(function() {
window.addEventListener('message', (event) => {
    if (event.data.type === 'loadStatusUpdate') {        
        document.getElementById('container').style.display = 'block';
        document.getElementById('load').style.width = event.data.percentage + '%';
        document.getElementById('load-percentage').textContent = event.data.load;
    }
    if (event.data.type === 'close') {
        document.getElementById('container').style.display = 'none';
    }
    });
});