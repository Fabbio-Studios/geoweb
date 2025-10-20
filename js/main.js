document.addEventListener('DOMContentLoaded', function(){
  if(window.AOS) AOS.init({duration:700, once:true, offset:100});

  // Smooth scroll for internal links (additional to css scroll-behavior)
  document.querySelectorAll('a[href^="#"]').forEach(a=>{
    a.addEventListener('click', function(e){
      const href = this.getAttribute('href');
      if(href.length>1){
        e.preventDefault();
        const el = document.querySelector(href);
        if(el) el.scrollIntoView({behavior:'smooth', block:'start'});
      }
    });
  });

  // Ensure hero background loads correctly (document-relative path). This helps
  // when the CSS-relative path fails (file:// vs server differences).
  try {
    const wallpaperPath = 'assets/images/wallpaper.jpg';
    function applyToElement(el){
      const img = new Image();
      img.onload = function(){
        el.style.backgroundImage = `url('${wallpaperPath}')`;
        el.style.backgroundSize = 'cover';
        el.style.backgroundPosition = 'center';
        document.body.classList.add('has-wallpaper');
      };
      img.onerror = function(){
        console.warn('Wallpaper não encontrado em ' + wallpaperPath + '. Usando fallback de cor.');
        el.style.backgroundImage = 'linear-gradient(180deg, rgba(139,195,74,0.12), rgba(250,244,230,0.06))';
      };
      img.src = wallpaperPath;
    }

    const hero = document.querySelector('.hero');
    if(hero){
      applyToElement(hero);
    } else {
      // Apply wallpaper to body for pages without a hero section (about, materials)
      applyToElement(document.body);
    }
  } catch(e){
    console.error('Erro ao aplicar wallpaper:', e);
  }

  // Navbar contrast toggle on scroll
  (function(){
    const nav = document.querySelector('.navbar');
    if(!nav) return;
    function check(){
      if(window.scrollY > 30) nav.classList.add('scrolled'); else nav.classList.remove('scrolled');
    }
    check();
    window.addEventListener('scroll', check, {passive:true});
  })();
});