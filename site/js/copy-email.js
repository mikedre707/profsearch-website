// Copies the business email to the clipboard from any .copy-email button.
document.addEventListener('click', function (e) {
  var btn = e.target.closest('.copy-email');
  if (!btn) return;
  var email = 'mike@profsearch.net';
  function done() {
    var old = btn.textContent;
    btn.textContent = 'Copied!';
    btn.disabled = true;
    setTimeout(function () { btn.textContent = old; btn.disabled = false; }, 2000);
  }
  if (navigator.clipboard && navigator.clipboard.writeText) {
    navigator.clipboard.writeText(email).then(done, function () { window.prompt('Copy the address:', email); });
  } else {
    window.prompt('Copy the address:', email);
  }
});
