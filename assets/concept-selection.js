(()=>{
 'use strict';
 const KEY='rules_concept_selection_v1';
 const data=window.RULES_CONCEPTS||[];
 const byId=new Map(data.map(item=>[item.id,item]));
 let memory=[];
 function read(){try{const value=JSON.parse(localStorage.getItem(KEY)||'[]');return Array.isArray(value)?[...new Set(value.filter(id=>typeof id==='string'&&byId.has(id)))]:[]}catch{return memory}}
 function write(items){memory=items;try{localStorage.setItem(KEY,JSON.stringify(items));return true}catch{return false}}
 function announce(message){document.querySelectorAll('[data-selection-status]').forEach(el=>{el.textContent=message})}
 function render(){const selected=read();document.querySelectorAll('[data-concept-toggle]').forEach(btn=>{const active=selected.includes(btn.dataset.conceptToggle);btn.textContent=active?'УБРАТЬ ИЗ ВЫБОРА':'СОХРАНИТЬ АРОМАТ';btn.setAttribute('aria-pressed',String(active))});document.querySelectorAll('[data-selection-count]').forEach(el=>{el.textContent=String(selected.length)});
 const list=document.querySelector('[data-selection-list]');if(!list)return;list.replaceChildren();if(!selected.length){const p=document.createElement('p');p.className='selection-empty';p.textContent='Пока ничего не сохранено. Открой каталог и выбери аромат, который тебе интересен.';list.append(p);return}
 for(const id of selected){const x=byId.get(id),row=document.createElement('article');row.className='selection-row';const info=document.createElement('div'),meta=document.createElement('small'),link=document.createElement('a'),button=document.createElement('button');meta.textContent=x.collection;link.textContent=x.name;link.href='fragrances/'+x.page+'.html';button.type='button';button.textContent='УБРАТЬ';button.setAttribute('aria-label','Убрать '+x.name);button.addEventListener('click',()=>{let persisted=write(read().filter(y=>y!==id));render();announce(persisted?'Аромат удалён из выбора.':'Аромат удалён. Сохранение в браузере недоступно.')});info.append(meta,link);row.append(info,button);list.append(row)}}
 document.querySelectorAll('[data-concept-toggle]').forEach(btn=>btn.addEventListener('click',()=>{const id=btn.dataset.conceptToggle;if(!byId.has(id))return;const items=read(),exists=items.includes(id);const saved=write(exists?items.filter(x=>x!==id):[...items,id]);render();announce(saved?(exists?'Аромат удалён из выбора.':'Аромат сохранён в этом браузере.'):'Сохранение в браузере недоступно: выбор останется только на этой странице.')}));
 window.addEventListener('storage',e=>{if(e.key===KEY)render()});render();
})();
