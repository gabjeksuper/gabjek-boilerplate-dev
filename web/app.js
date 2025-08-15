
let visible = false;
window.addEventListener('message', (e) => {
  const d = e.data || {};
  if (d.action === 'toggle') {
    visible = !!d.state;
    document.getElementById('panel').classList.toggle('hidden', !visible);
    if (d.title) document.getElementById('title').textContent = d.title;
    if (d.subtitle) document.getElementById('subtitle').textContent = d.subtitle;
    if (d.btn) document.getElementById('btnlabel').textContent = d.btn;
  }
});
function post(name, body) {
  fetch(`https://${GetParentResourceName()}/${name}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
    body: JSON.stringify(body || {}),
  });
}
document.getElementById('close').addEventListener('click', () => post('close', {}));
document.getElementById('send').addEventListener('click', () => {
  const msg = (document.getElementById('msg').value || '').trim();
  post('notify', { message: msg.length ? msg : null });
});
document.getElementById('progress').addEventListener('click', () => post('progress', {}));
