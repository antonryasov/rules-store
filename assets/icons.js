/* Stable vector symbols instead of platform emoji glyphs. */
(()=>{const ns='http://www.w3.org/2000/svg';function icon(ch){const svg=document.createElementNS(ns,'svg');svg.setAttribute('viewBox','0 0 24 24');svg.setAttribute('aria-hidden','true');svg.classList.add('brand-icon');const path=document.createElementNS(ns,'path');if(ch==='↗')path.setAttribute('d','M5 19 19 5 M8 5 H19 V16');else{svg.classList.add('brand-icon-star');path.setAttribute('d','M10.6 1h2.8l.8 7.8L20 3l1 1-5.8 5.8 7.8.8v2.8l-7.8.8L21 20l-1 1-5.8-5.8-.8 7.8h-2.8l-.8-7.8L4 21l-1-1 5.8-5.8-7.8-.8v-2.8l7.8-.8L3 4l1-1 5.8 5.8z')}svg.append(path);return svg}
function replaceText(node){if(!node||node.nodeType!==3||!/[↗✳]/.test(node.data))return;const parent=node.parentElement;if(!parent||parent.closest('script,style,textarea,svg,option,[data-no-icon]'))return;const pieces=node.data.split(/([↗✳])/);if(pieces.length===1)return;const frag=document.createDocumentFragment();for(const part of pieces){if(part==='↗'||part==='✳')frag.append(icon(part));else if(part)frag.append(document.createTextNode(part))}node.replaceWith(frag)}
function scan(root){if(root.nodeType===3){replaceText(root);return}if(root.nodeType!==1||root.matches('script,style,textarea,svg,option,[data-no-icon]'))return;const walker=document.createTreeWalker(root,NodeFilter.SHOW_TEXT);const texts=[];while(walker.nextNode())texts.push(walker.currentNode);texts.forEach(replaceText)}
scan(document.body);const observer=new MutationObserver(records=>{for(const r of records){if(r.type==='characterData')scan(r.target);else for(const n of r.addedNodes)scan(n)}});observer.observe(document.body,{childList:true,subtree:true,characterData:true});})();

/* RULES. mobile navigation: all URLs resolve relative to the published site. */
(()=>{
 const script=document.currentScript, header=document.querySelector('header.header');
 if(!script||!header||header.querySelector('[data-rules-mobile-tools]'))return;
 const base=new URL('../',script.src),url=path=>new URL(path,base).href;
 const style=document.createElement('style');
 style.textContent=`
 .rules-mobile-tools,.rules-mobile-nav{display:none}
 @media(max-width:1100px){
  header.header{gap:8px!important}
  header.header .head-right{display:none!important}
  header.header .rules-mobile-tools{display:flex!important;align-items:center;justify-content:flex-end;gap:2px;margin-left:auto;flex-shrink:0}
  .rules-mobile-tools a,.rules-mobile-tools button{box-sizing:border-box;display:flex!important;align-items:center;justify-content:center;width:42px;height:44px;padding:9px;border:0;background:transparent;color:#172d2d;text-decoration:none;cursor:pointer}
  .rules-mobile-tools svg{width:23px;height:23px;fill:none;stroke:currentColor;stroke-width:1.7;stroke-linecap:round;stroke-linejoin:round}
  .rules-mobile-tools a:focus-visible,.rules-mobile-tools button:focus-visible,.rules-mobile-nav a:focus-visible{outline:2px solid #116069;outline-offset:2px}
  .rules-mobile-nav:not([hidden]){display:grid!important;position:relative;z-index:50;grid-template-columns:1fr;background:#10282a;color:#fff;padding:10px max(5%,20px) 16px;box-sizing:border-box}
  .rules-mobile-nav[hidden]{display:none!important}
  .rules-mobile-nav a{display:block;padding:12px 2px;border-bottom:1px solid #ffffff2a;color:#fff;text-decoration:none;font:700 13px/1.35 Manrope,Arial,sans-serif;letter-spacing:.02em}
  .rules-mobile-nav a:last-child{border-bottom:0}
 }
 `;document.head.append(style);
 const tools=document.createElement('div');tools.className='rules-mobile-tools';tools.dataset.rulesMobileTools='';
 const account=document.createElement('a');account.href=url('account.html');account.setAttribute('aria-label','Личный кабинет');account.innerHTML='<svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="8" r="3.4"/><path d="M5 20c.4-4.1 2.9-6.3 7-6.3s6.6 2.2 7 6.3"/></svg>';
 const cart=document.createElement('a');cart.href=url('cart.html');cart.setAttribute('aria-label','Корзина');cart.innerHTML='<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M4 7h16l-1 13H5L4 7z"/><path d="M9 8V6a3 3 0 0 1 6 0v2"/></svg>';
 const toggle=document.createElement('button');toggle.type='button';toggle.setAttribute('aria-label','Открыть меню');toggle.setAttribute('aria-expanded','false');toggle.setAttribute('aria-controls','rules-mobile-nav');toggle.innerHTML='<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M3 6h18M3 12h18M3 18h18"/></svg>';tools.append(account,cart,toggle);header.append(tools);
 const menu=document.createElement('div');menu.id='rules-mobile-nav';menu.className='rules-mobile-nav';menu.hidden=true;menu.setAttribute('role','navigation');menu.setAttribute('aria-label','Мобильное меню');
 const links=[['Магазин','shop.html'],['Личный кабинет','account.html'],['Корзина','cart.html'],['Коллекции','index.html#collection'],['Атлас ароматов','catalog.html'],['Пробники','samplers.html'],['RULES. CLUB','club.html'],['Предложения','promos.html'],['Доставка и оплата','delivery.html'],['О бренде','about.html'],['Контакты','contacts.html']];
 for(const [label,path] of links){const a=document.createElement('a');a.href=url(path);a.textContent=label;menu.append(a)}header.insertAdjacentElement('afterend',menu);
 function setOpen(open){menu.hidden=!open;toggle.setAttribute('aria-expanded',String(open));toggle.setAttribute('aria-label',open?'Закрыть меню':'Открыть меню')}
 toggle.addEventListener('click',()=>setOpen(menu.hidden));menu.addEventListener('click',e=>{if(e.target.closest('a'))setOpen(false)});document.addEventListener('keydown',e=>{if(e.key==='Escape'&&!menu.hidden){setOpen(false);toggle.focus()}});document.addEventListener('click',e=>{if(!menu.hidden&&!header.contains(e.target)&&!menu.contains(e.target))setOpen(false)});window.matchMedia('(min-width: 1101px)').addEventListener('change',e=>{if(e.matches)setOpen(false)});
})();
