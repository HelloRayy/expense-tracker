import fs from 'fs';

const attachmentHtml = fs.readFileSync('attachment-design.html', 'utf-8');

// Let's verify and apply to index.html
console.log('Attachment loaded, length:', attachmentHtml.length);
