async function shortenUrl() {
  const longUrl = document.getElementById('longUrl').value;
  const resultDiv = document.getElementById('shortenedUrl');
  const copyButton = document.getElementById('copyButton');

  if (!longUrl) {
    showResult('<p style="color: #ff6b6b;">Please enter a URL</p>');
    return;
  }

  try {
    const response = await fetch('https://qi65jb566f.execute-api.us-east-1.amazonaws.com/shorten', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ longURL: longUrl }),
    });

    const data = await response.json();

    if (response.ok) {
      resultDiv.innerHTML = `
        <p>Your shortened URL:</p>
        <a href="${data.shortURL}" target="_blank">${data.shortURL}</a>
      `;
      copyButton.style.display = 'block'; // Show the copy button
    } else {
      showResult(`<p style="color: #ff6b6b;">Error: ${data.error}</p>`);
    }
  } catch (error) {
    showResult(`<p style="color: #ff6b6b;">Error: ${error.message}</p>`);
  }
}

function copyToClipboard() {
  const shortUrlElement = document.querySelector('#shortenedUrl a');
  const tempTextArea = document.createElement('textarea');
  tempTextArea.value = shortUrlElement.textContent;
  document.body.appendChild(tempTextArea);
  tempTextArea.select();
  document.execCommand('copy');
  document.body.removeChild(tempTextArea);
  alert('Copied to clipboard: ' + shortUrlElement.textContent);
}

function showResult(content) {
  const resultDiv = document.getElementById('result');
  resultDiv.innerHTML = content;
  resultDiv.classList.remove('fade-in');
  void resultDiv.offsetWidth; // Trigger reflow
  resultDiv.classList.add('fade-in');
}
