/* ─────────────────────────────────────────────
   작사 작업판 공용 엔진 (3채널 공통)

   페이지가 할 일: 데이터를 담아 window.WB 를 정의하고,
   <div id="board"></div> 와 <i id="pbar"> 진행바만 두면 된다.

   window.WB = {
     key:      'hangyeol4_done',        // localStorage 키 (작업판마다 다르게)
     songs:    SONGS,                   // 곡 배열
     tags:     s => [{t:'한형', hot:false}, ...],  // 곡 태그 칩
     lyrics:   s => s.lyrics,
     style:    s => s.style,            // 곡별 스타일 프롬프트
     excl:     s => EXCLUDE,            // 제외 프롬프트 (한 줄)
     yt:       s => s.yt,
     thumb:    s => s.thumb || null,    // 없으면 null (섹션 자체가 안 나옴)
     concept:  s => s.concept,
   }
   ───────────────────────────────────────────── */
(function(){
  const W = window.WB;
  if(!W){ console.error('WB 설정이 없습니다'); return; }
  const S = W.songs;
  let idx = 0;

  const board = document.getElementById('board');
  const pbar  = document.getElementById('pbar');

  const getDone = () => { try{ return JSON.parse(localStorage.getItem(W.key)||'[]'); }catch(e){ return []; } };
  const setDone = a => localStorage.setItem(W.key, JSON.stringify(a));

  const esc = t => String(t==null?'':t)
    .replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');

  board.innerHTML = `
    <div class="nav">
      <button class="navbtn" id="prev">◀ 이전 곡</button>
      <div class="dots" id="dots"></div>
      <button class="navbtn" id="next">다음 곡 ▶</button>
    </div>

    <div class="card">
      <div class="songhead">
        <div class="songno" id="songno">1</div>
        <div class="title" id="title"></div>
        <label class="donechk"><input type="checkbox" id="donebox">완료</label>
      </div>
      <div class="tags" id="tags"></div>
      <div class="concept" id="concept"></div>

      <div class="cols">
        <div class="pane">
          <div class="slabel"><span>① 가사 → 수노 Lyrics 칸</span>
            <button class="copybtn" data-copy="lyrics">가사 복사</button></div>
          <textarea class="lyrics" id="lyrics" readonly></textarea>
        </div>
        <div class="pane">
          <div class="slabel"><span>② 스타일 → 수노 Style 칸</span>
            <button class="copybtn" data-copy="style">스타일 복사</button></div>
          <textarea class="style" id="style" readonly></textarea>
        </div>
      </div>

      <div class="row">
        <b>③ 제외</b>
        <input id="excl" readonly>
        <button class="copybtn" data-copy="excl">복사</button>
      </div>

      <div class="row">
        <b>④ 유튜브 제목</b>
        <input class="yt" id="yt" readonly>
        <button class="copybtn" data-copy="yt">복사</button>
      </div>

      <div class="sect" id="thumbsect" style="display:none">
        <div class="slabel"><span>⑤ 썸네일 프롬프트 (ChatGPT 이미지)</span>
          <button class="copybtn" data-copy="thumb">복사</button></div>
        <textarea class="thumb" id="thumb" readonly></textarea>
      </div>
    </div>`;

  const $ = id => document.getElementById(id);
  const dotsEl = $('dots');
  S.forEach((_,i)=>{
    const b = document.createElement('button');
    b.className = 'dot'; b.textContent = i+1;
    b.onclick = () => { idx = i; render(); };
    dotsEl.appendChild(b);
  });

  const val = s => ({
    lyrics: W.lyrics(s),
    style:  W.style(s),
    excl:   W.excl(s),
    yt:     W.yt(s),
    thumb:  W.thumb ? W.thumb(s) : null,
  });

  board.querySelectorAll('.copybtn').forEach(btn=>{
    btn.onclick = () => {
      const text = val(S[idx])[btn.dataset.copy];
      const ok = () => {
        const o = btn.textContent;
        btn.textContent = '복사됨!'; btn.classList.add('done');
        setTimeout(()=>{ btn.textContent = o; btn.classList.remove('done'); }, 1200);
      };
      if(navigator.clipboard && navigator.clipboard.writeText){
        navigator.clipboard.writeText(text).then(ok).catch(()=>fallback(text, ok));
      } else fallback(text, ok);
    };
  });
  function fallback(t, ok){
    const ta = document.createElement('textarea');
    ta.value = t; document.body.appendChild(ta); ta.select();
    try{ document.execCommand('copy'); }catch(e){}
    document.body.removeChild(ta); ok();
  }

  $('donebox').onchange = () => {
    const a = getDone(), i = a.indexOf(idx);
    if($('donebox').checked && i < 0) a.push(idx);
    if(!$('donebox').checked && i >= 0) a.splice(i,1);
    setDone(a); paint();
  };
  $('prev').onclick = () => { if(idx > 0){ idx--; render(); } };
  $('next').onclick = () => { if(idx < S.length-1){ idx++; render(); } };
  document.addEventListener('keydown', e => {
    if(e.target.tagName === 'TEXTAREA' || e.target.tagName === 'INPUT') return;
    if(e.key === 'ArrowLeft')  $('prev').click();
    if(e.key === 'ArrowRight') $('next').click();
  });

  function paint(){
    const a = getDone();
    if(pbar) pbar.style.width = (a.length / S.length * 100) + '%';
    const cd = $('cdone'); if(cd) cd.textContent = a.length;
    document.querySelectorAll('.dot').forEach((d,i)=>{
      d.classList.toggle('active', i === idx);
      d.classList.toggle('finished', a.includes(i));
    });
  }

  function render(){
    const s = S[idx], v = val(s);
    $('songno').textContent = idx + 1;
    $('title').textContent  = s.title;
    const cn = $('cnow'); if(cn) cn.textContent = idx + 1;
    $('tags').innerHTML = (W.tags ? W.tags(s) : [])
      .map(t => `<span class="tag ${t.hot ? 'hot' : ''}">${esc(t.t)}</span>`).join('');
    $('concept').textContent = W.concept ? (W.concept(s) || '') : '';
    $('lyrics').value = v.lyrics;
    $('style').value  = v.style;
    $('excl').value   = v.excl;
    $('yt').value     = v.yt;
    if(v.thumb){ $('thumbsect').style.display = ''; $('thumb').value = v.thumb; }
    else       { $('thumbsect').style.display = 'none'; }
    $('donebox').checked = getDone().includes(idx);
    $('prev').disabled = idx === 0;
    $('next').disabled = idx === S.length - 1;
    paint();
    window.scrollTo({ top: 0, behavior: 'smooth' });
  }

  render();
})();
