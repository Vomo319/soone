// UI rendering functions

/**
 * Render a list of items into a container element.
 * @param {HTMLElement} container
 * @param {Array} items
 */
export function renderList(container, items) {
  if (!container) return;
  container.innerHTML = "";
  items.forEach(item => {
    const el = document.createElement("div");
    el.textContent = item;
    container.appendChild(el);
  });
}

/**
 * Show a toast/notification message.
 * @param {string} message
 * @param {string} type - "success" | "error" | "info"
 */
export function showToast(message, type = "info") {
  const toast = document.createElement("div");
  toast.className = `toast toast--${type}`;
  toast.textContent = message;
  document.body.appendChild(toast);
  setTimeout(() => toast.remove(), 3000);
}

/**
 * Toggle the visibility of an element.
 * @param {HTMLElement} el
 * @param {boolean} visible
 */
export function toggleVisible(el, visible) {
  if (!el) return;
  el.style.display = visible ? "" : "none";
}
