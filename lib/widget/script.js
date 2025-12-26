// created by @krasnovpro

import yaml from "./lib/yaml.js";
import { marked } from "./lib/marked.js";
// window.yaml = yaml;
// window.marked = marked;

// --- global state & configuration ---
window.ahk = window.chrome.webview.hostObjects.ahk;

window.codeToKey = codeToKey;
window.focusFuncs = focusFuncs;
window.moveWindow = moveWindow;
window.setCheckboxState = setCheckboxState;
window.syncIcons = syncIcons;
window.appState = {};

let hoverTimer;
let container;
let showHelp = false;

const active = {
  get:  (item) => item.classList.contains("active"),
  on: (item) => {
    item.classList.add("active");
    try {
      adjustSubmenuWithinViewport(item);
    } catch (e) {
      console.error(e);
    }
  },
  off:  (item) => item.classList.remove("active"),
  flip: (item) => item.classList.toggle("active"),
}

// cached dom elements for help
let helpElement, helpWrapper, helpContent, helpKeyIndicator;

// --- main initialization ---
document.addEventListener("DOMContentLoaded", main);

async function main() {
  appState = initializeAppState();

  if (!appState.dataFile) {
    console.error("Missing data file name");
    return;
  }

  if (!appState.windowType) {
    console.error("Missing window type");
    return;
  }

  switch (appState.windowType) {
    case "menu":
      container = await buildMenu(appState.dataFile, container);
      container.id = appState.windowType;
      document.body.appendChild(container);

      makeDraggable(container);
      moveWindow(appState.mouseX, appState.mouseY);
      syncIcons();

      if (appState.helpPath) {
        setupHelpBox(appState.winLeft, appState.winTop);
      }

      document.addEventListener("keydown"     , handleMenuKeyboard);
      document.addEventListener("click"       , handleMenuLeftClick);
      document.addEventListener("auxclick"    , handleMenuMiddleClick);
      document.addEventListener("contextmenu" , handleMenuRightClick);
      document.addEventListener("mouseover"   , handleMenuMouseOver);
      document.addEventListener("mouseout"    , handleMenuMouseOut);
      break;

    case "funcs":
      container = await buildFuncs(appState.dataFile);
      container.id = appState.windowType;
      document.body.appendChild(container);

      const tabNav = container.querySelector(":scope .nav");
      if (tabNav) tabNav.addEventListener("mousewheel", handleFuncsWheel);

      const tabContent = container.querySelector(":scope .content");
      if (tabContent) tabContent.addEventListener("mousewheel", handleCellsWheel);

      const handle = container.querySelector(":scope .nav.handle");
      if (handle) {
        handle.style.cursor = "grab";
        handle.addEventListener("mousedown", handleFuncsDrag);
      }

      document.addEventListener("keydown"     , handleFuncsKeyboard);
      document.addEventListener("click"       , handleFuncsLeftClick);
      document.addEventListener("contextmenu" , handleFuncsRightClick);
      break;

    case "window":
      container = await buildWindow(appState.dataFile);
      container.id = appState.windowType;
      document.body.appendChild(container);

      makeDraggable(container);
      moveWindow(appState.mouseX, appState.mouseY);

      document.addEventListener("keydown", handleWindowKeyboard);
      document.addEventListener("click", handleWindowLeftClick);
      break;
  }

  if (appState.stylesFile) {
    addStylesheet(appState.stylesFile);
  }

  if (appState.spritesFile) {
    addSvgSprites(appState.spritesFile);
  }
}

// --- event handlers ---
function handleWindowKeyboard(event) {
  if (event.code === "Escape") {
    ahk.hide();
  }

  if (event.code === "F10") {
    setCheckboxState('showMenuAtMousePos', true);
    hideMenu();
    return;
  }
}

function handleWindowLeftClick(event) {
  if (event.target === document.body) {
    ahk.hide();
  }
}

function handleMenuKeyboard(event) {
  const openedMenus = Array.from(document.querySelectorAll(".menu"))
    .filter((item) => active.get(item));

  if (openedMenus.length === 0) return;

  if (event.code === "Escape") {
    if (openedMenus.length === 1) {
      hideMenu();
    } else {
      active.off(openedMenus.at(-1));
    }
    return;
  }

  if (event.code === "F10") {
    setCheckboxState('rememberLastSubmenu', true);
    setCheckboxState('showMenuAtMousePos', true);
    hideMenu();
    return;
  }

  if (event.code === "F1") {
    toggleHelpDisplay();
    return;
  }

  const activeMenu = openedMenus.at(-1);
  const targetItem = activeMenu.querySelector(
    `:scope > .column > .item[data-key="${codeToKey(event.code)}"]`
  );
  if (targetItem) {
    targetItem.click();
  }
}

function handleMenuLeftClick(event) {
  // click on background
  if (event.target === document.body) {
    foldMenu();
    hideMenu();
    return;
  }

  // click on external link
  if (event.target.dataset.link) {
    ahk.open(event.target.dataset.link);
    event.stopPropagation();
    return;
  }

  // event.stopPropagation();
  const targetItem = event.target.closest(".item");
  if (!targetItem) return;


  // click on an item with an action
  if (targetItem.dataset.action) {
    foldMenu();
    hideMenu();
    ahk.fun(targetItem.dataset.action);
    return;
  }

  // click to toggle a submenu
  const subMenu = targetItem.querySelector(".menu");
  if (subMenu) {
    const subMenuState = active.get(subMenu);

    foldMenu("force");
    getAllClosest(event.target, '.menu', 'body').forEach((item) => active.on(item));

    if (subMenuState) {
      active.off(subMenu);
    } else {
      active.on(subMenu);
    }
  }
}

function handleMenuMiddleClick(event) {
  if (event.button === 1 && event.target === document.body) {
    foldMenu();
    hideMenu();
    return;
  }
}

function handleMenuRightClick(event) {
  event.preventDefault();
  foldMenu("force");
}

function handleMenuMouseOver(event) {
  if (!showHelp) return;

  const item = event.target.closest(".item"); // ".item:not(.title)"
  if (item && helpWrapper && helpContent) {
    clearTimeout(hoverTimer);
    hoverTimer = setTimeout(async () => {
      if (item.dataset.help) {
        active.on(helpWrapper);
        const content = await createHelpContent(item.dataset.help);
        helpContent.innerHTML = content;
      } else {
        helpContent.innerHTML = "";
        active.off(helpWrapper);
      }
    }, 300);
  }
}

function handleMenuMouseOut(event) {
  if (event.target.closest(".item")) {
    clearTimeout(hoverTimer);
  }
}

function handleFuncsDrag(event) {
  if (event.target !== event.currentTarget) return;
  event.preventDefault();
  event.stopPropagation();
  ahk.dragWindow();
}

function handleFuncsKeyboard(event) {
  if (event.code === "Escape") {
    ahk.hide();
    return;
  }

  if (event.code === "ArrowLeft" || (event.code === "Tab" && event.shiftKey)) {
    event.preventDefault();
    navigateTab("prev");
    return;
  }

  if (event.code === "ArrowRight" || (event.code === "Tab" && !event.shiftKey)) {
    event.preventDefault();
    navigateTab("next");
    return;
  }

  const tabNav = document.querySelector("#funcs .nav");
  const targetItem =
    tabNav?.querySelector(`:scope > .item[data-key="${codeToKey(event.code)}"]`);

  if (targetItem) {
    event.preventDefault();
    targetItem.click();
    return;
  }

  const tabContent = document.querySelector("#funcs .item.active .cells");
  const tabItem =
    tabContent?.querySelector(`[data-key="${codeToKey(event.code)}"]`);

  if (tabItem) {
    event.preventDefault();
    if (event.ctrlKey /* || event.shiftKey */) {
      if (tabItem.dataset.actionUp) {
        ahk.fun(tabItem.dataset.actionUp);
      }
    } else {
      if (tabItem.dataset.actionDown) {
        ahk.fun(tabItem.dataset.actionDown);
      }
    }
  }
}

function focusFuncs(state) {
  const container = document.querySelector("#funcs .nav");
  if (container) {
    if (state == "add") {
      container.classList.add("focused");
    } else {
      container.classList.remove("focused");
    }
  }
}

function handleFuncsLeftClick(event) {
  // if ((event.target === document.body)
  //   || (event.target === document.documentElement)) {
  //   ahk.hide();
  //   return;
  // }

  const targetItem = event.target.closest("#funcs .nav .item");

  if (targetItem) {
    const tabNavs = document.querySelectorAll("#funcs .nav .item");
    const tabContents = document.querySelectorAll("#funcs .content .item");

    tabNavs.forEach((navItem) => active.off(navItem));
    tabContents.forEach((contentItem) => active.off(contentItem));

    active.on(targetItem);

    const targetContent = document.getElementById(targetItem.dataset.tab);
    if (targetContent) {
      active.on(targetContent);
    } else {
      console.error('Content not found for tab:', targetItem.dataset.tab);
    }
  }
}

function handleFuncsRightClick(event) {
  event.preventDefault();
  // ahk.hide();
}

function handleFuncsWheel(event) {
  navigateTab((Math.sign(event.deltaY) < 0) ? "prev" : "next");
}

function handleCellsWheel(event) {
  event.preventDefault();
  event.stopPropagation();

  const targetItem = event.target.closest(".cells > div");
  if (!targetItem) return;

  if (Math.sign(event.deltaY) < 0) {
    ahk.fun(targetItem.dataset.actionUp);
  } else {
    ahk.fun(targetItem.dataset.actionDown);
  }
}

// --- ui interaction & utility functions ---
function navigateTab(direction) {
  const tabNav = document.querySelector("#funcs .nav");
  const activeItem = tabNav?.querySelector(".item.active");
  if (!activeItem) return;

  let targetItem;

  if (direction === "prev") {
    targetItem = activeItem.previousElementSibling;
    if (!targetItem?.classList.contains("item")) {
      targetItem = tabNav.querySelector(".item:last-child");
    }
  } else {
    targetItem = activeItem.nextElementSibling;
    if (!targetItem?.classList.contains("item")) {
      targetItem = tabNav.querySelector(".item:first-child");
    }
  }

  if (targetItem) {
    targetItem.click();
  }
}

function hideMenu() {
  if (helpContent) helpContent.innerHTML = "";
  if (helpWrapper) active.off(helpWrapper);
  ahk.hide();
}

function foldMenu(force = false) {
  if (!appState.rememberLastSubmenu || force) {
    document.querySelectorAll(".menu .menu").forEach((menu) => active.off(menu));
  }
}

function toggleHelpDisplay() {
  if (!helpKeyIndicator) return;
  active.flip(helpKeyIndicator);
  showHelp = !showHelp;

  if (!showHelp && helpContent && helpWrapper) {
    helpContent.innerHTML = "";
    active.off(helpWrapper);
  }
}

// Adjust submenu position so it stays inside the window.
function adjustSubmenuWithinViewport(subMenu) {
  if (!subMenu) return;

  if (subMenu.dataset._origMarginLeft === undefined) {
    subMenu.dataset._origMarginLeft = subMenu.style.marginLeft ?? "";
    subMenu.dataset._origMarginTop = subMenu.style.marginTop ?? "";
  }

  subMenu.style.marginLeft = "";
  subMenu.style.marginTop = "";

  // Run after layout so sizes are correct
  requestAnimationFrame(() => {
    const pad = 8; // minimal padding from window edges
    const rect = subMenu.getBoundingClientRect();

    let shiftX = 0;
    let shiftY = 0;

    if (rect.right > window.innerWidth - pad) {
      shiftX = (window.innerWidth - pad) - rect.right;
    }
    if (rect.left + shiftX < pad) {
      shiftX += pad - (rect.left + shiftX);
    }

    if (rect.bottom > window.innerHeight - pad) {
      shiftY = (window.innerHeight - pad) - rect.bottom;
    }
    if (rect.top + shiftY < pad) {
      shiftY += pad - (rect.top + shiftY);
    }

    // Apply adjustments by changing inline margin values (matches CSS positioning)
    if (shiftX !== 0) {
      const cur = parseFloat(getComputedStyle(subMenu).marginLeft) || 0;
      subMenu.style.marginLeft = `${cur + shiftX}px`;
    }
    if (shiftY !== 0) {
      const cur = parseFloat(getComputedStyle(subMenu).marginTop) || 0;
      subMenu.style.marginTop = `${cur + shiftY}px`;
    }
  });
}

async function createHelpContent(helpFile = "") {
  const extension = helpFile.split(".").pop().toLowerCase();
  const path = `${appState.helpPath}/${helpFile}`;

  if (!await fileExists(path)) {
    return `<div class="error">File not found:<br>${helpFile}</div>`;
  }

  switch (extension) {
    case "html":
    case "htm":
    case "txt":
      return `<iframe src="${path}"></iframe>`;

    case "md":
      const response = await fetch(path);
      if (!response.ok) {
        return `<div class="markdown">Error loading: ${helpFile}</div>`;
      }
      const mdText = await response.text();
      const html = marked.parse(mdText);
      return `<div class="markdown">${html}</div>`;

    case "jpeg":
    case "jpg":
    case "png":
    case "webp":
      return `<div><img src="${path}" alt="help">`;

    case "gif":
      return `
      <gif-player size="contain" speed="1" play repeat prerender src="${path}">
      </gif-player>`;

    case "mov":
      return `
      <video autoplay loop controls>
        <source src="${path}" type="video/mp4">
      </video>`;

    case "mp4":
    case "webm":
      return `
      <video autoplay loop controls>
        <source src="${path}" type="video/${extension}">
      </video>`;

    default:
      return `<div class="error">Unidentified file:<br>${helpFile}</div>`;
  }
}

function makeDraggable(element) {
  let isDragging = false;
  let initialX, initialY, originalZ;
  // track whether pointer moved enough to be considered a drag
  let dragMoved = false;
  let startClientX = 0, startClientY = 0;

  // ensure a single global click suppressor exists to block click after drag
  if (!document._widgetClickSuppressorAdded) {
    document._widgetClickSuppressorAdded = true;
    document.addEventListener(
      "click",
      (e) => {
        if (window.__widgetSuppressClick) {
          e.stopImmediatePropagation();
          e.preventDefault();
          window.__widgetSuppressClick = false;
        }
      },
      true // capture phase
    );
  }

  // const title = element.querySelector(":scope .handle") ?? element;
  const title = element.querySelector(":scope .menu.active") ?? element;
  title.style.cursor = "grab";
  title.addEventListener("mousedown", startDragging);

  function startDragging(event) {
    // Prevent dragging when clicking on form elements inside the title
    if (event.target.tagName.toLowerCase() === "input") {
      return;
    }

    const computedStyle = getComputedStyle(element);
    const currentX = parseFloat(computedStyle.left) || 0;
    const currentY = parseFloat(computedStyle.top) || 0;
    originalZ = computedStyle.zIndex;

    element.style.zIndex = 9999;
    element.style.left = `${currentX}px`;
    element.style.top = `${currentY}px`;

    title.style.cursor = "grabbing";

    // save pointer origin to detect small moves vs real drag
    startClientX = event.clientX;
    startClientY = event.clientY;
    initialX = event.clientX - currentX;
    initialY = event.clientY - currentY;
    dragMoved = false;
    isDragging = true;

    document.addEventListener("mousemove", onDragging);
    document.addEventListener("mouseup", stopDragging);
  }

  function onDragging(event) {
    if (isDragging) {
      event.preventDefault();

      const dx = event.clientX - startClientX;
      const dy = event.clientY - startClientY;
      // threshold: 5px movement
      if (!dragMoved && (dx * dx + dy * dy) > 25) {
        dragMoved = true;
      }

      let newX = event.clientX - initialX;
      let newY = event.clientY - initialY;

      const maxX = window.innerWidth - element.offsetWidth;
      const maxY = window.innerHeight - element.offsetHeight;

      newX = Math.max(0, Math.min(newX, maxX));
      newY = Math.max(0, Math.min(newY, maxY));

      element.style.left = `${newX}px`;
      element.style.top = `${newY}px`;
    }
  }

  function stopDragging() {
    if (isDragging) {
      isDragging = false;
      element.style.zIndex = originalZ;
      title.style.cursor = "grab";
      document.removeEventListener("mousemove", onDragging);
      document.removeEventListener("mouseup", stopDragging);

      // if the pointer actually moved, suppress the next click that follows
      if (dragMoved) {
        window.__widgetSuppressClick = true;
        // Fallback clear in case capture handler isn't run for some reason
        setTimeout(() => { window.__widgetSuppressClick = false; }, 0);
      }
    }
  }
}

function makeResizable(element, minWidth = 250, minHeight = 150) {
  const resizer = element.querySelector(".resizer");
  if (!resizer) return;

  let startX, startY, startWidth, startHeight;

  resizer.addEventListener("mousedown", startResizing);

  function startResizing(event) {
    event.preventDefault();
    event.stopPropagation(); // prevent drag from triggering
    startX = event.clientX;
    startY = event.clientY;
    startWidth = parseInt(getComputedStyle(element).width, 10);
    startHeight = parseInt(getComputedStyle(element).height, 10);

    document.addEventListener("mousemove", onResizing);
    document.addEventListener("mouseup", stopResizing);
  }

  function onResizing(e) {
    const newWidth = startWidth + (e.clientX - startX);
    const newHeight = startHeight + (e.clientY - startY);
    element.style.width = `${Math.max(newWidth, minWidth)}px`;
    element.style.height = `${Math.max(newHeight, minHeight)}px`;
  }

  function stopResizing() {
    document.removeEventListener("mousemove", onResizing);
    document.removeEventListener("mouseup", stopResizing);
    // refresh content that might need it, e.g., video or iframe
    const content = element.querySelector(".content");
    if (content) {
      content.innerHTML = content.innerHTML;
    }
  }
}

// --- asset loaders ---
function initializeAppState() {
  const state = {};
  (new URL(window.location.href).searchParams)
    .forEach((value, key) => state[key] = value);

  try {
    state.showFuncsAtMousePos = JSON.parse(
      localStorage.getItem("showFuncsAtMousePos")
    ) ?? true;
  } catch {
    state.showFuncsAtMousePos = true;
  }

  try {
    state.showMenuAtMousePos = JSON.parse(
      localStorage.getItem("showMenuAtMousePos")
    ) ?? true;
  } catch {
    state.showMenuAtMousePos = true;
  }

  try {
    state.rememberLastSubmenu = JSON.parse(
      localStorage.getItem("rememberLastSubmenu")
    ) ?? true;
  } catch {
    state.rememberLastSubmenu = true;
  }

  return state;
}

function setCheckboxState(item, state) {
  appState[item] = state;
  try {
    localStorage.setItem(item, state);
  } catch (e) {
    console.error("'" + item + "' saving error: ", e);
  }

  // update checkbox DOM state if an input with this id exists
  try {
    const el = document.getElementById(item);
    if (el && el.tagName && el.tagName.toLowerCase() === 'input') {
      // treat as checkbox if input type is checkbox
      if (el.type === 'checkbox' || el.getAttribute('type') === 'checkbox') {
        el.checked = !!state;
      }
    }
  } catch (e) {
    console.error("Error updating checkbox DOM for '", item, "':", e);
  }
}

function setupHelpBox(left, top) {
  [
    'lib/webcomponents-loader.js',
    'lib/gif-player.js',
  ].forEach((src) => {
    const script = document.createElement('script');
    script.src = src;
    document.head.appendChild(script);
  });

  const help = document.createElement("div");
  help.innerHTML = `
    <div id="help" style="
      left: ${parseInt(left) + 50}px;
      top: ${parseInt(top) + 50}px;
      display: flex;">
      <div class="handle">
        Press <span class="key">F1</span> to toggle help mode<br>
        <div class="small">
          then, hover the mouse over the menu items
          ending with a <span class="key mark">?</span> mark
        </div>
      </div>
      <div class="wrapper">
        <div class="content"></div>
        <div class="resizer"></div>
      </div>
    </div>
  `;
  document.body.appendChild(help);

  // Cache help elements
  helpElement = document.querySelector("#help");
  helpWrapper = helpElement.querySelector(".wrapper");
  helpContent = helpElement.querySelector(".content");
  helpKeyIndicator = helpElement.querySelector(".key");

  makeDraggable(helpElement);
  makeResizable(helpWrapper);
}

async function buildMenu(dataFile, container) {
  const rawYaml = await fetch(dataFile).then((r) => r.text());
  const data = yaml.load(rawYaml);
  return buildMenuItem(data, true);
}

function buildMenuItem(data, isRoot = false) {
  const container = document.createElement("div");
  container.className = "menu";

  let column = document.createElement("div");
  column.className = "column";
  container.appendChild(column);

  data.forEach((item, index) => {
    // separator
    if (!item || Object.keys(item).length === 0) {
      column.appendChild(document.createElement("hr"));
      return;

      // break column
    } else if (item.column === "break") {
      column = document.createElement("div");
      column.className = "column";
      container.appendChild(column);
      return;
    }

    // menu item
    const div = document.createElement("div");
    div.className = "item";

    if (item.action) div.dataset.action = JSON.stringify(item.action);
    if (item.help) div.dataset.help = item.help;

    // icon
    const icon = document.createElement("div");
    icon.className = "icon";
    if (item.icon) {
      if (typeof item.icon === "string") {
        icon.innerHTML = setIcon(item.icon);
      } else if (
        item.icon !== null
        && typeof item.icon === 'object'
        && !Array.isArray(item.icon)
      ) {
        const entry = Object.entries(item.icon)[0];
        const stateName = entry ? entry[0] : undefined;
        const stateIcons = entry ? entry[1] : {};
        if (stateName) {
          div.dataset.stateName = stateName;
          div.dataset.stateIcons = JSON.stringify(stateIcons);
        }
      }
    }
    div.appendChild(icon);

    if (!(isRoot && index === 0)) {
      // key
      const key = document.createElement("div");
      key.className = "key";
      div.dataset.key = item.key;
      key.innerHTML = item.key;

      switch (item.key) {
        case null:
        case undefined:
          key.className = "key empty";
          div.dataset.key = "";
          key.innerHTML = "";
          break;

        case "Space":
          key.innerHTML = "&#x2423;";
          break;

        case "Tab":
          key.innerHTML = "&#x21E5;";
          break;
      }
      div.appendChild(key);
    }

    // text
    const text = document.createElement("div");
    text.className = "text";
    if (item.text) text.innerHTML = item.text;
    if (item.hint) text.title = decodeHtmlEntities(item.hint);
    div.appendChild(text);

    if (isRoot && index === 0) {
      active.on(container);

      div.classList.add("handle");
      const conf = document.createElement("div");
      conf.className = "conf";
      conf.innerHTML = `
        <input id="showMenuAtMousePos" type="checkbox" tabindex="-1"
          title="Show menu next&#10;to the mouse cursor&#10;&#10;F10 - reset checkboxes"
          onclick="setCheckboxState('showMenuAtMousePos', this.checked);
          this.blur();"
          ${(appState.showMenuAtMousePos) ? 'checked' : ''}>
        <input id="rememberLastSubmenu" type="checkbox" tabindex="-1"
          title="Remember the&#10;last opened submenu&#10;&#10;Right-clicking anywhere&#10;collapses the menu."
          onclick="setCheckboxState('rememberLastSubmenu', this.checked);
          this.blur();"
          ${(appState.rememberLastSubmenu) ? 'checked' : ''}>
      `;
      div.appendChild(conf);
    }

    // external link to the documentation
    if (item.link) {
      const link = document.createElement("div");
      link.className = "link";
      link.title = "External link:\n" + item.link;
      link.dataset.link = item.link;
      div.appendChild(link);
    }


    // submenu
    if (Array.isArray(item.items)) {
      const subMenu = buildMenuItem(item.items);
      if (subMenu) div.appendChild(subMenu);
    }

    column.appendChild(div);
  });

  return container;
}

async function buildFuncs(path) {
  const rawYaml = await fetch(path).then((r) => r.text());
  const data = yaml.load(rawYaml);
  const container = document.createElement("div");

  container.innerHTML = `
    <div class="nav handle focused" title="Wheel, tab, left, right - cycle tabs">
      ${data.map((tab, i) => `
        <div data-tab="${tab.tab}" ${(tab.hint) && ('title="' + tab.hint + '"')}
          ${(tab.key) && ('data-key="' + ((tab.key === 'Space') ? " " : tab.key) + '"')}
          class="item${i === 0 ? ' active' : ''}">
          <svg><use href="${tab.icon}"></use></svg>
        </div>
      `).join('')}
      <div class="conf">
        <input id="showFuncsAtMousePos" type="checkbox" tabindex="-1"
          title="Show window next&#10;to the mouse cursor"
          onclick="setCheckboxState('showFuncsAtMousePos', this.checked);
          this.blur();"
        ${(appState.showFuncsAtMousePos) ? 'checked' : ''}>
      </div>
      <div class="close" title="Close" onclick="ahk.hide();"></div>
    </div>
    <div class="content">
      ${data.map((tab, i) => `
        <div class="item${i === 0 ? ' active' : ''}" id="${tab.tab}">
          <div class="text">${tab.text}</div>
          <div class="cells">
            ${tab.items.map(item => {
              let inner = "";
              if (item.icon) {
                inner += `<svg><use href="${item.icon}"></use></svg>`;
              }
              if (item.text) {
                inner += item.text;
              }

              const key = (item.key) ?
                `data-key="${item.key}"` : "";
              const title = (item.hint) ?
                `title="${item.hint}"` : "";
              const actionUp = (!!item?.action?.up) ?
                `data-action-up='${JSON.stringify(item.action.up)}'` : "";
              const actionDown = (!!item?.action?.down) ?
                `data-action-down='${JSON.stringify(item.action.down)}'` : "";

              return `
              <div ${title} ${key} ${actionUp} ${actionDown}>${inner}</div>
              `;
            }).join('')}
          </div>
        </div>
      `).join('')}
    </div>`;

  return container;
}

async function buildWindow(path) {
  const container = document.createElement("div");

  try {
    const response = await fetch(path);
    if (!response.ok) {
      throw new Error(`Error loading file "${path}"`);
    }

    container.innerHTML = await response.text();

    container.querySelectorAll("script").forEach((script) => {
      const newScript = document.createElement("script");
      if (script.src) {
        newScript.src = script.src;
      } else {
        newScript.textContent = script.textContent;
      }
      script.parentNode.replaceChild(newScript, script);
    });
  } catch (e) {
    container.innerHTML = `<p>Error: ${e.message}</p>`;
  }

  return container;
}

function addStylesheet(url) {
  const link = document.createElement("link");
  link.rel = "stylesheet";
  link.href = url;
  document.head.appendChild(link);
}

async function addSvgSprites(url) {
  const response = await fetch(url);
  const svgContent = await response.text();
  const parser = new DOMParser();
  const svgDoc = parser.parseFromString(svgContent, "image/svg+xml");
  const svgSprites = svgDoc.querySelector("svg");
  svgSprites.style.display = "none";
  document.body.prepend(svgSprites);
}

function setIcon(item) {
  if (item.startsWith("#") || item.includes(".svg#")) {
    return `<svg><use href="${item}"></use></svg>`;
  } else {
    return `<img src="${item}">`;
  }
}

function getAllClosest(start, selector, untilSelector) {
  const result = [];
  for (
    let el = start?.closest(selector);
    el;
    el = el.parentElement?.closest(selector) ?? null
  ) {
    if (untilSelector && el.matches(untilSelector)) break;
    result.push(el);
  }
  return Object.freeze(result);
};

function moveWindow(x = appState.mouseX, y = appState.mouseY) {
  // centering horizontally
  let left, top;
  if ( (appState.offsetX === "center")
    && (appState.winLeft !== undefined)
    && (appState.winRight !== undefined)
  ) {
    const workWidth = Number(appState.winRight) - Number(appState.winLeft);
    left = Number(appState.winLeft) + (workWidth - container.offsetWidth) / 2;
  } else {
    left = Number(x) + Number(appState.offsetX);
  }

  // centering vertically
  if ( (appState.offsetY === "center")
    && (appState.winTop !== undefined)
    && (appState.winBottom !== undefined)
  ) {
    const workHeight = Number(appState.winBottom) - Number(appState.winTop);
    top = Number(appState.winTop) + (workHeight - container.offsetHeight) / 2;
  } else {
    top = Number(y) + Number(appState.offsetY);
  }

  if (
    appState.showMenuAtMousePos ||
    !(container.style.left && container.style.top)
  ) {
    container.style.left = `${left}px`;
    container.style.top  = `${top}px`;
  }
}

function syncIcons(states) {
  if (typeof states === 'undefined') return

  Object.entries(JSON.parse(states)).forEach(([ state, value ]) => {
    document.querySelectorAll('.item[data-state-name="' + state + '"]')
      .forEach((item) => {
        const icons = JSON.parse(item.dataset.stateIcons);
        const iconDiv = item.querySelector('.icon');
        if (icons[value]) iconDiv.innerHTML = setIcon(icons[value]);
      }
    );
  });
}

async function fileExists(url) {
  try {
    const response = await fetch(url, { method: 'HEAD' });
    return response.ok; // true если 200–299
  } catch (e) {
    return false;
  }
}

// keycodes
function codeToKey(code) {
  const codeToKeyMap = {
    KeyA: 'a', KeyB: 'b', KeyC: 'c', KeyD: 'd', KeyE: 'e',
    KeyF: 'f', KeyG: 'g', KeyH: 'h', KeyI: 'i', KeyJ: 'j',
    KeyK: 'k', KeyL: 'l', KeyM: 'm', KeyN: 'n', KeyO: 'o',
    KeyP: 'p', KeyQ: 'q', KeyR: 'r', KeyS: 's', KeyT: 't',
    KeyU: 'u', KeyV: 'v', KeyW: 'w', KeyX: 'x', KeyY: 'y', KeyZ: 'z',

    Digit1: '1', Digit2: '2', Digit3: '3', Digit4: '4', Digit5: '5',
    Digit6: '6', Digit7: '7', Digit8: '8', Digit9: '9', Digit0: '0',

    Backquote: '`', Comma: ',', Period: '.', Minus: '-', Equal: '=',
    BracketLeft: '[', BracketRight: ']', Backslash: '\\\\', Slash: '/',
    Semicolon: ';', Quote: '\'', ContextMenu: '&equiv;',
  }

  return codeToKeyMap[code] ?? code;
}

function decodeHtmlEntities(str) {
  const textarea = document.createElement("textarea");
  textarea.innerHTML = str;
  return textarea.value;
}