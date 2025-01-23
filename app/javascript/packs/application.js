import Rails from "@rails/ujs";
import Turbolinks from "turbolinks";
import * as ActiveStorage from "@rails/activestorage";
import "channels";

Rails.start();
Turbolinks.start();
ActiveStorage.start();

// DOMContentLoaded イベント後にリクエストを送信
document.addEventListener('DOMContentLoaded', function() {
  // fetch を使ってリクエストを送信
  fetch('/add_memo', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      // CSRFトークンを追加しない
    },
    body: JSON.stringify({
      weekKey: "2025-1-20",
      dayIndex: 3,
      memo: {
        text: "x",
        startTime: "12:00",
        endTime: "13:00",
        important: false
      }
    })
  })
  .then(response => {
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    return response.json();
  })
  .then(data => console.log(data))
  .catch(error => console.error('Error:', error));
});
