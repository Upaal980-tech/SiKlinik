const K="siklinik.app.v4",$=s=>document.querySelector(s);
const esc=s=>String(s??"").replace(/[&<>"]/g,c=>({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;"}[c]));
const rp=n=>"Rp "+Math.round(+n||0).toLocaleString("id-ID");
const now=()=>new Date().toISOString(),ld=i=>new Date(i).toLocaleDateString("en-CA"),today=()=>ld(now()),fut=n=>ld(Date.now()+n*864e5);
const fd=i=>new Date(i).toLocaleDateString("id-ID",{day:"2-digit",month:"short",year:"numeric"});
const ft=i=>new Date(i).toLocaleTimeString("id-ID",{hour:"2-digit",minute:"2-digit"}).replace(".",":");
const fdt=i=>fd(i)+", "+ft(i);
const find=(a,id)=>a.find(x=>x.id==id)||{};
const nid=a=>Math.max(0,...a.map(x=>x.id))+1;
const hs=p=>{try{return btoa(unescape(encodeURIComponent(p)))}catch(e){return p}};
const dl=sd=>Math.round((new Date(sd)-new Date(today()))/864e5);
const ST={A:"Menunggu dokter",B:"Menunggu obat",C:"Menunggu bayar",E:"Selesai"};
const SC={[ST.A]:"am",[ST.B]:"bl",[ST.C]:"rs",[ST.E]:"tl"};
const bdg=s=>`<span class="bg ${SC[s]}">${s}</span>`;
const PR={pendaftaran:"Petugas Pendaftaran",dokter:"Dokter",apoteker:"Apoteker",kasir:"Kasir",manajer:"Manajer Operasional",platform:"Tim SiKlinik"};
const RL={pendaftaran:"Pendaftaran",dokter:"Dokter",apoteker:"Apoteker",kasir:"Kasir",manajer:"Manajer",platform:"Tim SiKlinik"};
const R={pendaftaran:[["Antrean Hari Ini","users"],["Pasien & Kunjungan","userplus"],["Jadwal Dokter","cal"]],dokter:[["Pasien Hari Ini","steth"],["Jadwal Dokter","cal"]],apoteker:[["Resep Masuk","pill"],["Penyerahan Obat","box"],["Stok Obat per Batch","boxes"]],kasir:[["Tagihan & Pembayaran","rcpt"],["Struk Hari Ini","print"]],manajer:[["Dashboard","dash"],["Laporan Bulanan","repf"],["Kelola Akun","userset"],["Layanan & Tarif","dollar"],["Jadwal Dokter","cal"],["Log Akses","shield"]],platform:[["Daftar Klinik","bld"],["Paket Langganan","pkg"],["Tagihan Langganan","file"],["Impor Data Pasien","cloud"]]};
const HR=["Min","Sen","Sel","Rab","Kam","Jum","Sab"];
const I={users:'<path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M22 21v-2a4 4 0 0 0-3-3.87M16 3.13a4 4 0 0 1 0 7.75"/>',userplus:'<path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M19 8v6M22 11h-6"/>',cal:'<rect x="3" y="4" width="18" height="18" rx="2"/><path d="M16 2v4M8 2v4M3 10h18"/>',steth:'<path d="M11 2v2M5 2v2M5 3H4a2 2 0 0 0-2 2v4a6 6 0 0 0 12 0V5a2 2 0 0 0-2-2h-1"/><path d="M8 15a6 6 0 0 0 12 0v-3"/><circle cx="20" cy="10" r="2"/>',pill:'<path d="m10.5 20.5 10-10a4.95 4.95 0 1 0-7-7l-10 10a4.95 4.95 0 1 0 7 7Z"/><path d="m8.5 8.5 7 7"/>',box:'<path d="m16 16 2 2 4-4"/><path d="M21 10V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l2-1.14"/><path d="m7.5 4.27 9 5.15M3.29 7 12 12l8.71-5M12 22V12"/>',boxes:'<path d="m12 2 10 5-10 5L2 7l10-5Z"/><path d="m2 17 10 5 10-5M2 12l10 5 10-5"/>',rcpt:'<path d="M4 2v20l2-1 2 1 2-1 2 1 2-1 2 1 2-1 2 1V2l-2 1-2-1-2 1-2-1-2 1-2-1-2 1Z"/><path d="M16 8h-6a2 2 0 1 0 0 4h4a2 2 0 1 1 0 4H8M12 17.5v-11"/>',print:'<path d="M6 9V2h12v7M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"/><rect x="6" y="14" width="12" height="8"/>',chart:'<path d="M3 3v18h18"/><path d="m7 14 4-4 3 3 5-6"/>',tag:'<path d="M12 2H2v10l9.3 9.3a1 1 0 0 0 1.4 0l8.6-8.6a1 1 0 0 0 0-1.4Z"/><circle cx="7" cy="7" r="1.5"/>',file:'<path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8Z"/><path d="M14 2v6h6M8 13h8M8 17h5"/>',bld:'<path d="M5 21V4a1 1 0 0 1 1-1h8a1 1 0 0 1 1 1v17M15 9h3a1 1 0 0 1 1 1v11M3 21h18M9 7h2M9 11h2M9 15h2"/>',pkg:'<path d="m7.5 4.27 9 5.15"/><path d="M21 8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16Z"/><path d="m3.3 7 8.7 5 8.7-5M12 22V12"/>',cloud:'<path d="M4 14.9A7 7 0 1 1 15.7 8h1.8a4.5 4.5 0 0 1 2.5 8.2"/><path d="M12 12v9M16 16l-4-4-4 4"/>',shield:'<path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10Z"/><path d="m9 12 2 2 4-4"/>',mon:'<path d="M2 3h20M21 3v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V3M8 21l4-4 4 4"/>',out:'<path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4M16 17l5-5-5-5M21 12H9"/>',alert:'<circle cx="12" cy="12" r="10"/><path d="M12 8v4M12 16h.01"/>',warn:'<path d="m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3Z"/><path d="M12 9v4M12 17h.01"/>',power:'<path d="M12 2v10M18.4 6.6a9 9 0 1 1-12.77.04"/>',refresh:'<path d="M3 12a9 9 0 0 1 9-9 9.75 9.75 0 0 1 6.74 2.74L21 8"/><path d="M21 3v5h-5M21 12a9 9 0 0 1-9 9 9.75 9.75 0 0 1-6.74-2.74L3 16"/><path d="M8 16H3v5"/>',plus:'<path d="M5 12h14M12 5v14"/>',check:'<path d="M20 6 9 17l-5-5"/>',ccheck:'<circle cx="12" cy="12" r="10"/><path d="m9 12 2 2 4-4"/>',card:'<rect x="2" y="5" width="20" height="14" rx="2"/><path d="M2 10h20"/>',x:'<path d="M18 6 6 18M6 6l12 12"/>',lock:'<rect x="4" y="11" width="16" height="10" rx="2"/><path d="M8 11V7a4 4 0 0 1 8 0v4"/>',pulse:'<path d="M3 12h4l3-8 4 16 3-8h4"/>',dash:'<rect x="3" y="3" width="7" height="9" rx="1"/><rect x="14" y="3" width="7" height="5" rx="1"/><rect x="14" y="12" width="7" height="9" rx="1"/><rect x="3" y="16" width="7" height="5" rx="1"/>',repf:'<path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8Z"/><path d="M14 2v6h6M8 18v-4M12 18v-6M16 18v-2"/>',userset:'<circle cx="9" cy="7" r="4"/><path d="M2 21v-2a4 4 0 0 1 4-4h4"/><circle cx="18" cy="17" r="2.5"/><path d="M18 12.5v2M18 19.5v2M13.5 17h2M20.5 17h2"/>',dollar:'<circle cx="12" cy="12" r="10"/><path d="M16 8h-6a2 2 0 1 0 0 4h4a2 2 0 1 1 0 4H8M12 18V6"/>',edit:'<path d="M17 3a2.85 2.83 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5Z"/>',trash:'<path d="M3 6h18M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6M8 6V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2M10 11v6M14 11v6"/>',mail:'<rect x="2" y="4" width="20" height="16" rx="2"/><path d="m22 7-10 6L2 7"/>',clock:'<circle cx="12" cy="12" r="10"/><path d="M12 6v6l4 2"/>'};
const ic=(n,s=18)=>`<svg viewBox="0 0 24 24" width="${s}" height="${s}" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">${I[n]}</svg>`;

function seed(){
 const dy=(n,h,m)=>{const d=new Date(Date.now()-n*864e5);d.setHours(h,m,0,0);return d.toISOString()},pw=hs("siklinik123");
 const obat=[[1,"Amoxicillin 500 mg","kapsul",1500,20],[2,"Paracetamol 500 mg","tablet",500,50],[3,"Cetirizine 10 mg","tablet",1000,20],[4,"Ibuprofen 400 mg","tablet",800,30],[5,"Omeprazole 20 mg","kapsul",2500,20],[6,"OBH Sirup 100 ml","botol",18000,10],[7,"Vitamin C 500 mg","tablet",600,50]].map(o=>({id:o[0],n:o[1],s:o[2],h:o[3],min:o[4]}));
 const layanan=[[1,"Konsultasi Dokter Umum",75000,"Konsultasi"],[2,"Konsultasi Dokter Spesialis Anak",150000,"Konsultasi"],[3,"Perawatan Luka Ringan",60000,"Tindakan"],[4,"Nebulizer",85000,"Tindakan"],[5,"Pemeriksaan Gula Darah",35000,"Laboratorium"],[6,"Pemeriksaan Kolesterol",45000,"Laboratorium"],[7,"Biaya Administrasi",10000,"Administrasi"]].map(l=>({id:l[0],n:l[1],t:l[2],k:l[3]}));
 const lp=id=>layanan.find(x=>x.id===id).t,op=id=>obat.find(x=>x.id===id).h;
 const hp=(ls,rs)=>ls.reduce((a,l)=>a+lp(l),0)+rs.reduce((a,r)=>a+r[1]*op(r[0]),0);
 const hist=[[1,9,[1],[[1,15,"3x1 dihabiskan"],[2,10,"3x1 bila demam"]],"Demam, batuk","Infeksi saluran napas"],[3,10,[1],[[3,7,"1x1 malam"]],"Bersin dan gatal","Rinitis alergi"],[2,11,[1],[[1,15,"3x1 dihabiskan"],[4,6,"2x1 bila nyeri"]],"Nyeri gigi","Infeksi gigi"],[1,12,[1,5],[[5,10,"1x1 sebelum makan pagi"]],"Nyeri ulu hati","Gastritis"],[3,13,[1],[[6,1,"3x1 sendok makan"],[2,6,"3x1 bila demam"]],"Batuk berdahak","Bronkitis ringan"],[2,14,[1,6],[[7,10,"1x1 pagi"]],"Mudah lelah","Hiperkolesterolemia"],[1,15,[1],[[2,10,"3x1 sesudah makan"]],"Demam","Demam tidak spesifik"],[2,1,[1],[[2,10,"3x1 bila demam"]],"Demam","Demam tidak spesifik"],[3,2,[1],[[1,15,"3x1 dihabiskan"]],"Nyeri tenggorokan","Faringitis akut"],[1,3,[1,3],[[4,6,"2x1 bila nyeri"]],"Luka di kaki","Vulnus excoriatum"],[2,4,[1,5],[[7,10,"1x1 pagi"],[2,6,"3x1 bila demam"]],"Lemas","Anemia ringan"],[3,5,[1],[[5,10,"1x1 sebelum makan pagi"]],"Perih ulu hati","Dispepsia"],[1,6,[1],[[3,7,"1x1 malam"]],"Bersin","Rinitis alergi"]];
 const kj=[],by=[],ak=[];
 hist.forEach((h,i)=>{const id=i+1,T=hp(h[2],h[3]);kj.push({id,p:h[0],d:2,tgl:dy(h[1],9,20),a:1,j:"onsite",s:ST.E,l:h[2],r:h[3].map(r=>({o:r[0],j:r[1],a:r[2]})),rm:{kel:h[4],vit:"",dx:h[5],tin:""},sr:{u:4,t:dy(h[1],9,35)}});by.push({id,k:id,tgl:dy(h[1],9,50),j:T,m:"Tunai",u:5,terima:T});ak.push({t:dy(h[1],9,21),u:2,a:"lihat",o:"rekam medis",p:h[0],k:""},{t:dy(h[1],9,28),u:2,a:"buat",o:"rekam medis",p:h[0],k:"Diagnosis: "+h[5]})});
 const b=hist.length;
 kj.push({id:b+1,p:1,d:2,tgl:dy(0,8,30),a:1,j:"onsite",s:ST.C,l:[1],r:[{o:2,j:10,a:"3x1 bila demam"}],rm:{kel:"Demam dan batuk 2 hari",vit:"TD 120/80, suhu 37,8 C",dx:"ISPA ringan",tin:"Istirahat cukup"},sr:{u:4,t:dy(0,8,45)}});
 kj.push({id:b+2,p:3,d:2,tgl:dy(0,9,0),a:2,j:"onsite",s:ST.B,l:[1],r:[{o:3,j:5,a:"1x1 malam"},{o:7,j:10,a:"1x1 pagi"}],rm:{kel:"Bersin dan gatal",vit:"TD 110/70",dx:"Rinitis alergi",tin:"Hindari pemicu"}});
 kj.push({id:b+3,p:2,d:2,tgl:dy(0,9,15),a:3,j:"online",s:ST.A,l:[],r:[],rm:null});
 ak.push({t:dy(0,8,35),u:2,a:"buat",o:"rekam medis",p:1,k:"Diagnosis: ISPA ringan"},{t:dy(0,9,5),u:2,a:"buat",o:"rekam medis",p:3,k:"Diagnosis: Rinitis alergi"});
 const jd=[];[[2,1,"08:00","15:00"],[2,2,"08:00","15:00"],[2,3,"08:00","15:00"],[2,4,"13:00","20:00"],[2,5,"08:00","15:00"],[2,6,"08:00","12:00"],[3,1,"15:00","20:00"],[3,3,"15:00","20:00"]].forEach((s,i)=>jd.push({id:i+1,d:s[0],hari:s[1],a:s[2],b:s[3],p:"Poli Umum"}));
 return{
  akun:[[1,"pendaftaran","Putri Anggraini","pendaftaran"],[2,"dokter","dr. Fajar Nugroho","dokter"],[3,"dokter2","dr. Sinta Maharani","dokter"],[4,"apoteker","apt. Lina Marlina","apoteker"],[5,"kasir","Bayu Saputra","kasir"],[6,"manajer","Ratna Dewi","manajer"]].map(a=>({id:a[0],u:a[1],n:a[2],r:a[3],e:"",m:1,h:pw,on:1,t:"terpadu"})).concat([{id:7,u:"admin",n:"Tim SiKlinik",r:"platform",e:"",m:1,h:hs("admin123"),on:1,t:"siklinik"}]),
  pasien:[[1,"RM-000001","1571012003900001","Dinna","1990-03-20","P","Telanaipura, Jambi","081200000001"],[2,"RM-000002","1571011507880002","Rasyid","1988-07-15","L","Kotabaru, Jambi","081200000002"],[3,"RM-000003","1571014409950003","Adinata","1995-09-04","L","Jelutung, Jambi","081200000003"]].map(p=>({id:p[0],no:p[1],nik:p[2],n:p[3],l:p[4],jk:p[5],al:p[6],tl:p[7],t:"terpadu",c:dy(40,10,0)})),
  obat,
  stok:[[1,1,"AMX-01",120,"2027-06-30"],[2,2,"PCT-01",200,"2026-12-20"],[3,2,"PCT-02",150,"2027-08-31"],[4,3,"CTZ-01",9,"2027-03-31"],[5,4,"IBU-01",18,"2027-05-31"],[6,5,"OMP-01",60,"2027-09-30"],[7,6,"OBH-01",25,"2027-02-28"],[8,7,"VTC-01",300,"2027-10-31"]].map(s=>({id:s[0],o:s[1],b:s[2],j:s[3],e:s[4]})),
  layanan,jadwal:jd,kunjungan:kj,bayar:by,log:[],akses:ak,
  klinik:[{id:1,c:"medikautama",n:"Klinik Medika Utama",p:"Basic",sd:fut(81),on:1,u:6,ps:1},{id:2,c:"sehatsentosa",n:"Klinik Sehat Sentosa",p:"Pro",sd:fut(-4),on:1,u:6,ps:7},{id:3,c:"terpadu",n:"Klinik Terpadu",p:"Pro",sd:fut(-3),on:1,u:0,ps:0}],
  paket:[{id:1,n:"Basic",h:299000,mx:5,f:["Pendaftaran & antrean","Rekam medis","Kasir"]},{id:2,n:"Pro",h:599000,mx:15,f:["Semua fitur Basic","Apotek & stok per batch","Dashboard manajer"]},{id:3,n:"Enterprise",h:1299000,mx:50,f:["Semua fitur Pro","Multi-poli","Impor data & dukungan prioritas"]}],
  tagL:[{id:1,k:1,j:299000,tempo:fut(-25),lunas:1},{id:2,k:1,j:299000,tempo:fut(81),lunas:0},{id:3,k:2,j:599000,tempo:fut(-4),lunas:0},{id:4,k:3,j:599000,tempo:fut(-3),lunas:0}]
 }
}

let D=null, U=null, V="", S={};

const save=()=>{ 
    fetch('/api/sync', { 
        method: 'POST', 
        headers: { 'Content-Type': 'application/json' }, 
        body: JSON.stringify(D) 
    }).catch(e=>console.error("Gagal simpan ke server:", e)); 
};

const lg=(a,e,i)=>D.log.push({t:now(),u:U?U.id:0,a,e,i});
const tot=o=>D.stok.filter(s=>s.o==o&&s.e>=today()).reduce((a,s)=>a+s.j,0);
const items=k=>[...k.l.map(i=>{const l=find(D.layanan,i);return{n:l.n,q:1,h:l.t,g:"Layanan"}}),...k.r.map(r=>{const o=find(D.obat,r.o);return{n:o.n+" ("+o.s+")",q:r.j,h:o.h,g:"Obat"}})];
const total=k=>items(k).reduce((a,i)=>a+i.q*i.h,0);
const pn=id=>find(D.pasien,id),dn=id=>find(D.akun,id).n||"-",aq=k=>"A"+String(k.a).padStart(3,"0");
const sno=b=>"STR-"+ld(b.tgl).replace(/-/g,"")+"-"+String(b.id).padStart(4,"0");
const age=l=>Math.floor((Date.now()-new Date(l))/31557600000);
const ph=(eb,t,sub,act)=>`<div class="ph"><div><div class="eb">${eb}</div><h1>${t}</h1><p>${sub||""}</p></div>${act?`<div style="display:flex;gap:10px;flex-wrap:wrap">${act}</div>`:""}</div>`;
const ib=(n,t,c,fn)=>`<button class="btn ${c||""}" onclick="${fn}" style="display:inline-flex;gap:8px;align-items:center">${ic(n,17)}${t}</button>`;
const tbl=(h,rows,empty)=>rows.length?`<div class="tw"><table><thead><tr>${h.map(x=>`<th>${x}</th>`).join("")}</tr></thead><tbody>${rows.map(r=>`<tr>${r.map(c=>`<td>${c}</td>`).join("")}</tr>`).join("")}</tbody></table></div>`:`<p class="mu">${empty}</p>`;
let tt;function toast(m){const t=$("#toast");t.textContent=m;t.className="on";clearTimeout(tt);tt=setTimeout(()=>t.className="",2800)}
function modal(t,b){const m=$("#modal");m.innerHTML=`<div class="mb"><div class="mh"><h3>${t}</h3><button onclick="closeM()" aria-label="Tutup">${ic("x",22)}</button></div>${b}</div>`;m.style.display="grid"}
function closeM(){$("#modal").style.display="none"}

/* ---------- login ---------- */
const LG='<div class="logo"><b class="lm">'+ic("pulse",20)+'</b>SiKlinik</div>';
const QL={pendaftaran:"Pendaftaran",dokter:"Dokter",apoteker:"Apoteker",kasir:"Kasir",manajer:"Manajer"};
const lp=()=>`<div class="lp">${LG}<div><div class="pill">terpadu.siklinik.id</div><h1>Satu data pasien,<br><em>dari loket hingga kasir.</em></h1><p>Pendaftaran, rekam medis, e-resep, apotek, dan kasir terhubung otomatis. Data dibuat sekali, dipakai ulang, tanpa entri ulang, terisolasi per klinik.</p><div class="ft"><div><b class="mono">RBAC</b>Menu sesuai peran</div><div><b class="mono">MFA</b>Login 2 langkah</div><div><b class="mono">Audit</b>Log akses rekam medis</div></div></div></div>`;
function loginHTML(){
 if(S.mfa)return `<div class="login">${lp()}<div class="rp"><div class="fm"><div class="eb">LANGKAH 2 DARI 2</div><h2>Verifikasi MFA</h2><p class="ds">Masukkan kode 6 digit untuk akun <b>${esc(S.mfa.n)}</b>. Kode demo: <b class="mono">123456</b></p><label class="fl">Kode MFA<div class="in"><input id="lc" class="mono" inputmode="numeric" maxlength="6" placeholder="123456" autocomplete="one-time-code" onkeydown="if(event.key==='Enter')mfa()"></div></label><div class="err" id="le"></div><button class="pb" onclick="mfa()">Masuk</button><button class="gb" onclick="S.mfa=0;render()">Kembali</button></div></div></div>`;
 return `<div class="login">${lp()}<div class="rp"><div class="fm"><div class="eb">LANGKAH 1 DARI 2</div><h2>Masuk ke portal</h2><p class="ds">Gunakan kode klinik (subdomain), username, dan password Anda.</p>
 <label class="fl">Kode klinik<div class="in">${ic("bld","1.3em")}<input id="lk" class="mono" value="terpadu" oninput="chk()" autocapitalize="off" spellcheck="false" onkeydown="ent(event)"><span class="mono sf">.siklinik.id</span></div></label>
 <label class="fl">Username<div class="in"><input id="lu" autocomplete="username" autocapitalize="off" oninput="chk()" onkeydown="ent(event)"></div></label>
 <label class="fl">Password<div class="in">${ic("lock","1.3em")}<input id="lp" type="password" autocomplete="current-password" oninput="chk()" onkeydown="ent(event)"></div></label>
 <div class="err" id="le"></div><button class="pb" id="go" onclick="login()" disabled>Lanjut ke verifikasi MFA</button></div></div></div>`}
const err=m=>{$("#le").textContent=m};
const ent=e=>{if(e.key==="Enter")login()};
function chk(){const b=$("#go");if(b)b.disabled=!($("#lk").value.trim()&&$("#lu").value.trim()&&$("#lp").value)}
function login(){const k=$("#lk").value.trim().toLowerCase(),u=$("#lu").value.trim(),c=D.klinik.find(x=>x.c===k);
 if(k!=="siklinik"&&!c)return err("Kode klinik tidak ditemukan.");
 if(c&&!c.on)return err("Klinik ini sedang nonaktif.");
 const a=D.akun.find(x=>x.t===k&&x.u===u);
 if(!a||a.h!==hs($("#lp").value)||!a.on)return err("Username atau password salah, atau akun nonaktif.");
 S.mfa=a;render()}
function mfa(){if($("#lc").value.trim()!=="123456")return err("Kode MFA salah.");const a=S.mfa;S.mfa=0;enter(a)}
function quick(r){const a=D.akun.find(x=>x.t==="terpadu"&&x.r===r&&x.on);if(a)enter(a);else toast("Tidak ada akun aktif untuk peran ini")}
function enter(a){U=a;V=R[a.r][0][0];S={};lg("login","akun",a.id);save();render()}
function out(){lg("logout","akun",U.id);save();U=null;S={};closeM();render()}
function go(m){V=m;S={};render()}
let _cb=null;function ask(msg,fn){_cb=fn;modal("Konfirmasi",`<p style="margin:0 0 18px">${msg}</p><div style="display:flex;gap:10px"><button class="btn" style="flex:1" onclick="closeM()">Batal</button><button class="btn p" style="flex:1" onclick="_cb&&_cb()">Ya, lanjutkan</button></div>`)}
function resetDemo(){ask("Hapus semua data demo dan kembalikan ke awal?",()=>{try{localStorage.removeItem(K)}catch(e){}location.reload()})}
document.addEventListener("keydown",e=>{if(e.key==="Escape")closeM()});

/* ---------- shell ---------- */
function alerts(){let h="";
 if(U.r==="apoteker"||U.r==="manajer")D.obat.filter(o=>tot(o.id)<o.min).forEach(o=>h+=`<div class="al y">${ic("warn",22)}<span><b>Stok menipis:</b> Stok ${esc(o.n)} menipis: tersisa ${tot(o.id)} ${o.s} (min. ${o.min})</span></div>`);
 if(U.r==="platform")D.klinik.filter(c=>c.on&&dl(c.sd)<=7).sort((a,b)=>dl(a.sd)-dl(b.sd)).forEach(c=>{const d=dl(c.sd);h+=d<0?`<div class="al r">${ic("alert",22)}<span><b>Langganan:</b> Langganan ${c.c}.siklinik.id sudah lewat jatuh tempo ${-d} hari</span></div>`:`<div class="al y">${ic("warn",22)}<span><b>Langganan:</b> Langganan ${c.c}.siklinik.id jatuh tempo ${d===0?"hari ini":d+" hari lagi"}</span></div>`});
 if(U.r==="manajer"){const c=D.klinik.find(x=>x.c===U.t);if(c&&dl(c.sd)<=7){const d=dl(c.sd);h+=`<div class="al r">${ic("alert",22)}<span><b>Langganan:</b> Langganan SiKlinik untuk ${c.c}.siklinik.id ${d<0?"sudah lewat jatuh tempo "+(-d)+" hari":"jatuh tempo dalam "+d+" hari"} (${c.sd}). Hubungi Tim SiKlinik untuk perpanjangan.</span></div>`}}
 return h}
const VW={};
function render(){
 const app=$("#app");
 if(!D) return app.innerHTML = '<div style="display:flex;justify-content:center;align-items:center;height:100vh;font-family:sans-serif;color:#5f7384">Memuat data dari Server...</div>';
 if(!U){app.innerHTML=loginHTML();return}
 const pf=U.t==="siklinik"?"admin":U.t,kn=U.t==="siklinik"?"Tim SiKlinik":(D.klinik.find(c=>c.c===U.t)||{}).n;
 if(!VW[V])V=R[U.r][0][0];
 app.innerHTML=`<div class="shell"><aside><div class="brand"><b class="lm">${ic("pulse",24)}</b><div><b>SiKlinik</b><small>SISTEM KLINIK</small></div></div><div class="pc"><small>${U.t==="siklinik"?"PORTAL ADMIN":"PORTAL KLINIK"}</small><b>${esc(kn)}</b><span class="mono">${pf}.siklinik.id</span></div><nav>${R[U.r].map(m=>`<button class="nv ${m[0]===V?"on":""}" onclick="go('${m[0]}')">${ic(m[1],20)}${m[0]}</button>`).join("")}</nav><div class="sec">${ic("shield",16)}Sesi terenkripsi · MFA aktif</div></aside><div class="mn"><header class="tb"><span class="dot"></span><span class="mono">${pf}.siklinik.id</span><div class="tr"><div class="us"><b>${esc(U.n)}</b><span class="rl ${U.r}">${RL[U.r]}</span></div><button class="btn" onclick="out()">${ic("out",16)}Keluar</button></div></header><main>${alerts()}${VW[V]()}</main></div></div>`;
 if($("#rows")&&!$("#rows").children.length)addRow();
}

/* ---------- pendaftaran ---------- */
VW["Antrean Hari Ini"]=()=>{const l=D.kunjungan.filter(k=>ld(k.tgl)===today()).sort((a,b)=>a.a-b.a),c=s=>l.filter(k=>k.s===s).length;
 return ph("PENDAFTARAN","Antrean Hari Ini","Pantau nomor antrean, dokter tujuan, dan status setiap kunjungan secara real-time.",ib("userplus","Cari / Daftar Pasien","p","go('Pasien & Kunjungan')"))
 +`<div class="stats"><div class="st"><small>Total kunjungan</small><b>${l.length}</b></div><div class="st am"><small>Menunggu dokter</small><b>${c(ST.A)}</b></div><div class="st"><small>Menunggu bayar</small><b>${c(ST.C)}</b></div><div class="st gr"><small>Selesai</small><b>${c(ST.E)}</b></div></div>
 <div class="card">${tbl(["No","Pasien","Dokter","Jenis","Jam","Status"],l.map(k=>[`<span class="mono">${aq(k)}</span>`,`<b>${esc(pn(k.p).n)}</b><small class="mono">${pn(k.p).no}</small>`,esc(dn(k.d)),k.j,ft(k.tgl),bdg(k.s)]),"Belum ada kunjungan hari ini.")}</div>`};
VW["Pasien & Kunjungan"]=()=>{const q=(S.q||"").toLowerCase(),pk=S.pick?pn(S.pick):null,dow=new Date().getDay(),dok=D.akun.filter(a=>a.r==="dokter"&&a.on&&a.t===U.t);
 const l=D.pasien.filter(p=>p.t===U.t&&(!q||[p.n,p.nik,p.no].join(" ").toLowerCase().includes(q)));
 return ph("PENDAFTARAN","Pasien & Kunjungan","Cek Master Patient Index lebih dulu supaya data pasien tidak ganda.")
 +`<div class="g2"><div>${pk?`<div class="card" style="border:2px solid var(--bl)"><h3>Kunjungan untuk ${esc(pk.n)}</h3><small class="mono">${pk.no} · lahir ${fd(pk.l)}</small><div class="fr"><label>Dokter<select id="kd">${dok.map(d=>{return `<option value="${d.id}">${esc(d.n)}${D.jadwal.some(s=>s.d===d.id&&s.hari===dow)?"":" (tidak praktik hari ini)"}</option>`}).join("")}</select></label><label>Jenis pendaftaran<select id="kj"><option>onsite</option><option>online</option></select></label></div><button class="btn p" onclick="kunj()">Daftarkan kunjungan</button> <button class="btn" onclick="S.pick=0;render()">Batal</button></div>`:""}
 <div class="card"><h3>Pasien baru</h3><div class="fr"><label>NIK (16 digit)<input id="pn" inputmode="numeric" maxlength="16"></label><label>Nama lengkap<input id="pm"></label><label>Tanggal lahir<input id="pl" type="date"></label><label>Jenis kelamin<select id="pj"><option value="L">Laki-laki</option><option value="P">Perempuan</option></select></label><label>Alamat<input id="pa"></label><label>No. telepon<input id="pt" inputmode="tel"></label></div><button class="btn p" onclick="baru()">Cek MPI dan simpan</button></div></div>
 <div class="card"><h3>Daftar pasien (MPI)</h3><div class="fr"><input id="q" placeholder="Cari nama, NIK, atau no. RM" value="${esc(S.q||"")}" onkeydown="if(event.key==='Enter')cari()"><button class="btn p" onclick="cari()">Cari</button></div>${tbl(["Pasien","Lahir","Telepon",""],l.map(p=>[`<b>${esc(p.n)}</b><small class="mono">${p.no}</small>`,fd(p.l),esc(p.tl),`<button class="btn" onclick="S.pick=${p.id};render()">Buat kunjungan</button>`]),"Belum ada pasien cocok.")}</div></div>`};
function cari(){S.q=$("#q").value.trim();S.pick=0;render()}
function mkP(p,t){p.t=t;p.c=now();p.id=nid(D.pasien);p.no="RM-"+String(D.pasien.filter(x=>x.t===t).length+1).padStart(6,"0");D.pasien.push(p);return p}
function baru(){const v=i=>$("#"+i).value.trim(),p={nik:v("pn"),n:v("pm"),l:v("pl"),jk:v("pj"),al:v("pa"),tl:v("pt")};
 if(!p.n||!p.l||!/^\d{16}$/.test(p.nik))return toast("Isi nama, tanggal lahir, dan NIK 16 digit");
 const d=D.pasien.find(x=>x.t===U.t&&(x.nik===p.nik||(x.n.toLowerCase()===p.n.toLowerCase()&&x.l===p.l)));
 if(d){S.pick=d.id;render();return toast("Pasien sudah ada di MPI, data lama dipakai")}
 mkP(p,U.t);lg("tambah","pasien",p.id);save();S.pick=p.id;render();toast("Pasien baru tersimpan: "+p.no)}
function kunj(){const n=D.kunjungan.filter(k=>ld(k.tgl)===today()).length+1,k={id:nid(D.kunjungan),p:S.pick,d:+$("#kd").value,tgl:now(),a:n,j:$("#kj").value,s:ST.A,l:[],r:[],rm:null};
 D.kunjungan.push(k);lg("tambah","kunjungan",k.id);save();S={};go("Antrean Hari Ini");toast("Kunjungan terdaftar, antrean "+aq(k))}

/* ---------- dokter ---------- */
VW["Pasien Hari Ini"]=()=>{if(S.cur)return exam();
 const m=D.kunjungan.filter(k=>k.d===U.id&&ld(k.tgl)===today()).sort((a,b)=>a.a-b.a),w=m.filter(k=>k.s===ST.A),sd=m.filter(k=>k.rm);
 const row=(k,r)=>`<div class="card" style="display:flex;align-items:center;gap:16px"><span class="mono bg bl">${aq(k)}</span><div><b style="font-size:17px">${esc(pn(k.p).n)}</b><small class="mono">${pn(k.p).no} · ${age(pn(k.p).l)} th · ${ft(k.tgl)}</small></div><div style="margin-left:auto">${r}</div></div>`;
 return ph("DOKTER","Pasien Hari Ini","Pasien yang terdaftar ke Anda hari ini. Buka form pemeriksaan untuk mengisi rekam medis dan e-resep.")
 +`<h3 class="sh">Menunggu pemeriksaan · ${w.length}</h3>${w.length?w.map(k=>row(k,`<button class="btn p" onclick="periksa(${k.id})">Periksa</button>`)).join(""):'<div class="card"><p class="mu">Tidak ada pasien menunggu.</p></div>'}
 <h3 class="sh">Sudah diperiksa · ${sd.length}</h3>${sd.map(k=>row(k,`<span class="mu" style="margin-right:10px">${esc(k.rm.dx)}</span>${bdg(k.s)}`)).join("")}`};
function exam(){const k=find(D.kunjungan,S.cur),p=pn(k.p),rw=D.kunjungan.filter(x=>x.p===k.p&&x.rm&&x.id!==k.id).sort((a,b)=>b.tgl.localeCompare(a.tgl));
 return ph("DOKTER","Pemeriksaan: "+esc(p.n),p.no+" · "+age(p.l)+" th · "+(p.jk==="L"?"Laki-laki":"Perempuan"))
 +`<div class="g2"><div><div class="card"><h3>Rekam medis</h3><div class="fr" style="grid-template-columns:1fr"><label>Keluhan<textarea id="f1"></textarea></label><label>Tanda vital<input id="f2" placeholder="TD, nadi, suhu"></label><label>Diagnosis<input id="f3"></label><label>Tindakan dan catatan<textarea id="f4"></textarea></label></div></div>
 <div class="card"><h3>Layanan</h3>${D.layanan.map(l=>`<label class="ck"><input type="checkbox" class="ly" value="${l.id}" ${l.id===1?"checked":""}>${esc(l.n)} <small style="display:inline">${rp(l.t)}</small></label>`).join("")}</div></div>
 <div><div class="card"><h3>E-resep</h3><div id="rows" style="margin-top:12px"></div><button class="btn" onclick="addRow()">+ Tambah obat</button></div>
 <div class="card"><h3>Riwayat pasien</h3>${rw.length?rw.map(x=>`<div class="row"><div><b>${esc(x.rm.dx)}</b><small>${fd(x.tgl)} · ${esc(dn(x.d))}<br>${esc(x.rm.kel)}</small></div></div>`).join(""):'<p class="mu">Belum ada riwayat sebelumnya.</p>'}</div>
 <button class="btn p" onclick="simpan()">Simpan pemeriksaan</button> <button class="btn" onclick="S.cur=0;render()">Batal</button></div></div>`}
function addRow(){const d=document.createElement("div");d.className="rr";d.innerHTML=`<select>${D.obat.map(o=>`<option value="${o.id}">${esc(o.n)} (stok ${tot(o.id)})</option>`).join("")}</select><input class="jm" type="number" min="1" placeholder="Jml"><input class="ar" placeholder="Aturan pakai"><button class="btn" onclick="this.parentNode.remove()" aria-label="Hapus">×</button>`;$("#rows").appendChild(d)}
function simpan(){const k=find(D.kunjungan,S.cur),v=i=>$("#"+i).value.trim();
 if(!v("f1")||!v("f3"))return toast("Isi keluhan dan diagnosis");
 k.rm={kel:v("f1"),vit:v("f2"),dx:v("f3"),tin:v("f4")};k.l=[...document.querySelectorAll(".ly:checked")].map(x=>+x.value);
 k.r=[...document.querySelectorAll(".rr")].map(r=>({o:+r.querySelector("select").value,j:+r.querySelector(".jm").value,a:r.querySelector(".ar").value.trim()})).filter(r=>r.j>0);
 k.s=k.r.length?ST.B:ST.C;ak("buat","rekam medis",k.p,"Diagnosis: "+k.rm.dx);lg("ubah","rekam_medis",k.id);save();S.cur=0;render();toast(k.r.length?"Tersimpan, e-resep dikirim ke apotek":"Tersimpan, tagihan siap di kasir")}

/* ---------- apoteker ---------- */
const obRow=(r,k)=>{const o=find(D.obat,r.o),t=tot(r.o);return `<div class="ob">${ic("pill",22)}<div><b>${esc(o.n)}</b><small>${esc(r.a)||"-"}</small></div><div class="q">${r.j} ${o.s}<br><small style="${k&&t<r.j?"color:var(--rs)":""}">stok ${t}</small></div></div>`};
const rxHead=(k,b)=>`<div class="top"><h3>${esc(pn(k.p).n)}</h3>${b}</div><div class="mt">${pn(k.p).no} · ${esc(dn(k.d))} · ${fdt(k.tgl)}</div>`;
VW["Resep Masuk"]=()=>{const l=D.kunjungan.filter(k=>k.s===ST.B);
 return ph("APOTEK","Resep Masuk","E-resep dari dokter masuk otomatis. Serahkan obat — stok dipotong per batch (kedaluwarsa terdekat lebih dulu).")
 +(l.length?`<div class="cg">${l.map(k=>`<div class="card rx">${rxHead(k,'<span class="bg am">Menunggu</span>')}<div class="bx">${k.r.map(r=>obRow(r,1)).join("")}</div><button class="btn p fw" onclick="serah(${k.id})">${ic("box",20)}Serahkan Obat</button></div>`).join("")}</div>`:'<div class="card"><p class="mu">Tidak ada resep yang menunggu.</p></div>')};
function serah(id){const k=find(D.kunjungan,id);for(const r of k.r)if(tot(r.o)<r.j)return toast("Stok "+find(D.obat,r.o).n+" tidak cukup");
 k.r.forEach(r=>{let n=r.j;D.stok.filter(s=>s.o==r.o&&s.e>=today()).sort((a,b)=>a.e<b.e?-1:1).forEach(s=>{const x=Math.min(n,s.j);s.j-=x;n-=x})});
 k.s=ST.C;k.sr={u:U.id,t:now()};lg("ubah","stok",id);save();render();toast("Obat diserahkan, stok diperbarui")}
VW["Penyerahan Obat"]=()=>{const l=D.kunjungan.filter(k=>k.sr).sort((a,b)=>b.sr.t.localeCompare(a.sr.t));
 return ph("APOTEK","Riwayat Penyerahan Obat","Resep yang sudah diserahkan ke pasien.")
 +(l.length?`<div class="cg">${l.map(k=>`<div class="card rx">${rxHead(k,'<span class="bg tl">Diserahkan</span>')}<div class="bx">${k.r.map(r=>obRow(r)).join("")}</div><div class="ft2">${ic("ccheck",18)}Diserahkan oleh ${esc(dn(k.sr.u))} · ${fdt(k.sr.t)}</div></div>`).join("")}</div>`:'<div class="card"><p class="mu">Belum ada penyerahan obat.</p></div>')};
VW["Stok Obat per Batch"]=()=>{const t=today(),w=fut(60);
 return ph("APOTEK","Stok Obat per Batch","Pantau jumlah, batch, dan tanggal kedaluwarsa.")
 +`<div class="g2"><div class="card">${tbl(["Obat","Harga","Stok aktif","Batch"],D.obat.map(o=>[`<b>${esc(o.n)}</b><small>${o.s}</small>`,rp(o.h),`<span class="mono">${tot(o.id)}</span>${tot(o.id)<o.min?' <span class="bg am">menipis</span>':""}`,D.stok.filter(s=>s.o===o.id).map(s=>`<small class="mono">${esc(s.b)}: ${s.j} · ${s.e<t?'<b style="color:var(--rs)">kedaluwarsa</b>':s.e<w?'<b style="color:#a86b00">segera '+fd(s.e)+"</b>":fd(s.e)}</small>`).join("")]),"")}</div>
 <div class="card"><h3>Tambah stok masuk</h3><div class="fr"><label>Obat<select id="so">${D.obat.map(o=>`<option value="${o.id}">${esc(o.n)}</option>`).join("")}</select></label><label>No. batch<input id="sb"></label><label>Jumlah<input id="sj" type="number" min="1"></label><label>Kedaluwarsa<input id="se" type="date"></label></div><button class="btn p" onclick="addStok()">Simpan stok</button></div></div>`};
function addStok(){const s={id:nid(D.stok),o:+$("#so").value,b:$("#sb").value.trim(),j:+$("#sj").value,e:$("#se").value};
 if(!s.b||s.j<1||!s.e)return toast("Lengkapi batch, jumlah, dan tanggal kedaluwarsa");D.stok.push(s);lg("tambah","stok_obat",s.id);save();render();toast("Stok ditambahkan")}

/* ---------- kasir ---------- */
VW["Tagihan & Pembayaran"]=()=>{const l=D.kunjungan.filter(k=>k.s===ST.C),k=l.find(x=>x.id===S.sel)||l[0];S.sel=k?k.id:0;const m=S.m||"Tunai";
 const head=ph("KASIR","Tagihan & Pembayaran","Tagihan terisi otomatis dari tindakan dokter dan e-resep — tanpa mengetik ulang data pasien.");
 if(!k)return head+'<div class="card"><p class="mu">Tidak ada tagihan yang menunggu pembayaran.</p></div>';
 const T=total(k),p=pn(k.p);
 return head+`<div class="g2" style="grid-template-columns:1fr 1fr"><div class="card lst"><h3>Menunggu pembayaran · ${l.length}</h3>${l.map(x=>`<button class="it ${x.id===k.id?"on":""}" onclick="S.sel=${x.id};S.m='Tunai';render()">${ic("rcpt",24)}<div><b>${esc(pn(x.p).n)}</b><span class="mono">${pn(x.p).no} · ${aq(x)} · ${fd(x.tgl)} · ${items(x).length} item</span></div><span class="am2">${rp(total(x))}</span></button>`).join("")}</div>
 <div class="card lst dtl"><div class="h"><small style="letter-spacing:.06em;text-transform:uppercase">Tagihan kunjungan · terisi otomatis</small><h2>${esc(p.n)}</h2><span class="mt">${p.no} · ${esc(dn(k.d))} · ${fd(k.tgl)}</span></div>
 ${items(k).map(i=>`<div class="ln"><span class="tg ${i.g==="Layanan"?"l":"o"}">${i.g}</span><div><b>${esc(i.n)}</b><span class="mono">${i.q} × ${rp(i.h)}</span></div><span class="pr">${rp(i.q*i.h)}</span></div>`).join("")}
 <div class="tt"><span>Total tagihan</span><b>${rp(T)}</b></div>
 <div class="pad"><b>Metode pembayaran</b><div class="sg">${["Tunai","QRIS","Debit"].map(x=>`<button class="${x===m?"on":""}" onclick="S.m='${x}';render()">${x}</button>`).join("")}</div>
 ${m==="Tunai"?`<label>Uang diterima (Rp)<div style="display:flex;gap:10px"><input id="tr" type="number" class="mono" value="${T}" oninput="kb(${T})"><button class="btn" onclick="$('#tr').value=${T};kb(${T})">Uang pas</button></div></label><p style="margin:10px 0 0">Kembalian: <b class="mono" id="kb">${rp(0)}</b></p>`:`<p class="mu" style="margin:0">Pembayaran ${m} sebesar ${rp(T)} dianggap lunas saat dicatat.</p>`}
 <button class="btn p fw" style="margin-top:16px" onclick="bayar(${k.id})">${ic("card",20)}Catat Pembayaran & Cetak Struk</button></div></div></div>`};
function kb(T){$("#kb").textContent=rp(Math.max(0,(+$("#tr").value||0)-T))}
function bayar(id){const k=find(D.kunjungan,id),T=total(k),m=S.m||"Tunai",tr=m==="Tunai"?+$("#tr").value:T;
 if(tr<T)return toast("Uang diterima kurang dari total tagihan");
 const b={id:nid(D.bayar),k:id,tgl:now(),j:T,m,u:U.id,terima:tr};D.bayar.push(b);k.s=ST.E;lg("tambah","pembayaran",b.id);save();S={};render();struk(b.id);toast("Pembayaran dicatat")}
function struk(id){const b=find(D.bayar,id),k=find(D.kunjungan,b.k),p=pn(k.p);
 modal("Struk Pembayaran",`<div class="rc"><div class="c"><b>${esc((D.klinik.find(c=>c.c===U.t)||{n:"SiKlinik"}).n.toUpperCase())}</b><div class="g">${U.t}.siklinik.id</div></div><hr>
 <div class="l2"><span>No</span><span>${sno(b)}</span></div><div class="l2"><span>Tgl</span><span>${fdt(b.tgl)}</span></div><div class="l2"><span>Pasien</span><span>${esc(p.n)}</span></div><div class="l2"><span>No. RM</span><span>${p.no}</span></div><div class="l2"><span>Dokter</span><span>${esc(dn(k.d))}</span></div><hr>
 ${items(k).map(i=>`<div>${esc(i.n)}</div><div class="l2 g"><span>${i.q} x ${i.h.toLocaleString("id-ID")}</span><span>${(i.q*i.h).toLocaleString("id-ID")}</span></div>`).join("")}<hr>
 <div class="l2"><b>TOTAL</b><b>${rp(b.j)}</b></div><div class="l2"><span>Bayar (${b.m})</span><span>${rp(b.terima)}</span></div><div class="l2"><span>Kembali</span><span>${rp(b.terima-b.j)}</span></div><hr>
 <div class="c g">Kasir: ${esc(dn(b.u))}<br>Terima kasih, semoga lekas sembuh</div></div>
 <button class="btn p fw nop" onclick="window.print()">${ic("print",20)}Cetak Struk</button>`)}
VW["Struk Hari Ini"]=()=>{const l=D.bayar.filter(b=>ld(b.tgl)===today()).sort((a,b)=>b.id-a.id);
 return ph("KASIR","Struk Hari Ini","Pembayaran lunas hari ini. Buka dan cetak ulang struk kapan saja.")
 +`<div class="stats" style="max-width:820px"><div class="st"><small>Transaksi</small><b>${l.length}</b></div><div class="st gr"><small>Penerimaan</small><b>${rp(l.reduce((a,b)=>a+b.j,0))}</b></div></div>
 <div class="card">${tbl(["No. Struk","Pasien","Waktu","Metode","Total","Aksi"],l.map(b=>{const p=pn(find(D.kunjungan,b.k).p);return[`<span class="mono">${sno(b)}</span>`,`${esc(p.n)}<small class="mono">${p.no}</small>`,fdt(b.tgl),b.m,`<span class="mono">${rp(b.j)}</span>`,`<button class="btn" onclick="struk(${b.id})">${ic("print",15)} Struk</button>`]}),"Belum ada pembayaran hari ini.")}</div>`};

const ak=(a,o,p,k)=>D.akses.push({t:now(),u:U.id,a,o,p,k:k||""});
function periksa(id){const k=find(D.kunjungan,id),n=D.kunjungan.filter(x=>x.p===k.p&&x.rm&&x.id!==id).length;ak("lihat","rekam medis",k.p,"");if(n)ak("lihat","riwayat rekam medis",k.p,n+" catatan");save();S.cur=id;render()}

/* ---------- manajer ---------- */
const HN=["Minggu","Senin","Selasa","Rabu","Kamis","Jumat","Sabtu"],HO=[1,2,3,4,5,6,0];
const kfmt=v=>v>=1e6?(Math.round(v/1e5)/10).toString().replace(".",",")+"jt":Math.round(v/1e3)+"rb";
const nice=m=>{const p=Math.pow(10,Math.floor(Math.log10(m))),f=m/p;return(f<=1?1:f<=2?2:f<=5?5:10)*p};
const gridT=mx=>{const st=nice(Math.max(mx,4000)/4);return{st,top:st*4}};
const sec=(t,b,i)=>`<div class="card lst"><div class="ch"><h3>${t}</h3>${i?ic(i,20):""}</div>${b}</div>`;
const emp=m=>`<p class="mu" style="text-align:center;padding:36px 0;margin:0">${m}</p>`;
const klinikNama=()=>(D.klinik.find(c=>c.c===U.t)||{n:"SiKlinik"}).n;
const svgH='<svg viewBox="0 0 1000 ';
function barSVG(vals,labels){const W=1000,H=300,L=62,R=16,T=18,B=34,w=W-L-R,h=H-T-B,g=gridT(Math.max(...vals)),bw=w/vals.length;
 let s=svgH+H+'" width="100%" role="img" aria-label="Grafik pendapatan harian" style="display:block">';
 for(let i=0;i<=4;i++){const y=T+h-h*i/4;s+=`<line x1="${L}" x2="${W-R}" y1="${y}" y2="${y}" stroke="#e4eaf0" stroke-dasharray="4 4"/><text x="${L-10}" y="${y+4}" text-anchor="end" font-size="13" fill="#5f7384">${kfmt(g.st*i)}</text>`}
 vals.forEach((v,i)=>{const bh=h*v/g.top,x=L+i*bw+bw*.2;s+=`<rect x="${x}" y="${T+h-bh}" width="${bw*.6}" height="${bh}" rx="3" fill="#0b7a5e"><title>${labels[i]}: ${rp(v)}</title></rect>`;if(i%2===0)s+=`<text x="${x+bw*.3}" y="${H-10}" text-anchor="middle" font-size="13" fill="#5f7384">${labels[i]}</text>`});
 return s+"</svg>"}
function lineSVG(rev,vis,lab){const W=1000,H=320,L=62,R=46,T=18,B=42,w=W-L-R,h=H-T-B,g=gridT(Math.max(...rev)),vt=Math.max(4,Math.ceil(Math.max(...vis)/4)*4),n=rev.length;
 const X=i=>L+w*i/(n-1),Yr=v=>T+h-h*v/g.top,Yv=v=>T+h-h*v/vt,P=(a,Y)=>a.map((v,i)=>[X(i),Y(v)]);
 const cl=y=>Math.min(T+h,Math.max(T,y)),sm=p=>p.map((q,i)=>{if(!i)return"M"+q[0]+","+q[1];const a=p[i-2]||p[i-1],b=p[i-1],d=p[i+1]||q;return"C"+(b[0]+(q[0]-a[0])/6)+","+cl(b[1]+(q[1]-a[1])/6)+" "+(q[0]-(d[0]-b[0])/6)+","+cl(q[1]-(d[1]-b[1])/6)+" "+q[0]+","+q[1]}).join("");
 const pr=P(rev,Yr),pv=P(vis,Yv);
 let s=svgH+H+'" width="100%" role="img" aria-label="Tren 7 hari pendapatan dan kunjungan" style="display:block"><defs><linearGradient id="gr" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#0b7a5e" stop-opacity=".22"/><stop offset="1" stop-color="#0b7a5e" stop-opacity="0"/></linearGradient></defs>';
 for(let i=0;i<=4;i++){const y=T+h-h*i/4;s+=`<line x1="${L}" x2="${W-R}" y1="${y}" y2="${y}" stroke="#e4eaf0" stroke-dasharray="4 4"/><text x="${L-10}" y="${y+4}" text-anchor="end" font-size="13" fill="#5f7384">${kfmt(g.st*i)}</text><text x="${W-R+10}" y="${y+4}" font-size="13" fill="#5f7384">${vt*i/4}</text>`}
 s+=`<path d="${sm(pr)} L${X(n-1)},${T+h} L${X(0)},${T+h}Z" fill="url(#gr)"/><path d="${sm(pr)}" fill="none" stroke="#0b7a5e" stroke-width="2.5"/><path d="${sm(pv)}" fill="none" stroke="#0ea5e9" stroke-width="2.5"/>`;
 lab.forEach((l,i)=>{s+=`<text x="${X(i)}" y="${H-12}" text-anchor="middle" font-size="13" fill="#5f7384">${l}</text>`});
 return s+"</svg>"}

VW["Dashboard"]=()=>{const t=today(),kt=D.kunjungan.filter(k=>ld(k.tgl)===t),pd=D.bayar.filter(b=>ld(b.tgl)===t).reduce((a,b)=>a+b.j,0),low=D.obat.filter(o=>tot(o.id)<o.min),pb=D.pasien.filter(p=>p.t===U.t&&p.c&&ld(p.c)===t).length;
 const days=[...Array(7)].map((_,i)=>{const d=new Date(Date.now()-(6-i)*864e5),s=ld(d);return{l:d.toLocaleDateString("id-ID",{weekday:"short"})+" "+d.getDate(),v:D.bayar.filter(b=>ld(b.tgl)===s).reduce((a,b)=>a+b.j,0),k:D.kunjungan.filter(k=>ld(k.tgl)===s).length}});
 const dk=D.akun.filter(a=>a.r==="dokter"&&a.t===U.t).map(a=>({n:a.n,c:kt.filter(k=>k.d===a.id).length})).filter(x=>x.c);
 return ph("MANAJER","Dashboard Klinik","Rekap kunjungan, pendapatan, dan stok obat — diperbarui otomatis dari aktivitas harian.")
 +`<div class="stats"><div class="st"><small>Kunjungan hari ini</small><b>${kt.length}</b><span class="sb">${kt.filter(k=>k.s===ST.A).length} menunggu dokter</span></div><div class="st gr"><small>Pendapatan hari ini</small><b>${rp(pd)}</b></div><div class="st"><small>Pasien baru</small><b>${pb}</b><span class="sb">terdaftar hari ini</span></div><div class="st am"><small>Stok menipis</small><b>${low.length}</b><span class="sb">obat di bawah minimum</span></div></div>`
 +sec("Tren 7 hari — pendapatan &amp; kunjungan",`<div class="pd">${lineSVG(days.map(d=>d.v),days.map(d=>d.k),days.map(d=>d.l))}<div class="lg"><span><i style="background:#0b7a5e"></i>Pendapatan (Rp, sumbu kiri)</span><span><i style="background:#0ea5e9"></i>Kunjungan (sumbu kanan)</span></div></div>`)
 +sec("Stok menipis",low.length?low.map(o=>`<div class="rw"><span>${esc(o.n)}</span><span class="mono"><b style="color:#a86b00">${tot(o.id)}</b> / min ${o.min}</span></div>`).join(""):emp("Semua stok aman."),"warn")
 +sec("Kunjungan per dokter hari ini",dk.length?dk.map(x=>`<div class="rw"><span>${esc(x.n)}</span><b class="mono">${x.c}</b></div>`).join(""):emp("Belum ada kunjungan."),"steth")};

/* laporan bulanan */
function rep(ym){const ks=D.kunjungan.filter(k=>ld(k.tgl).slice(0,7)===ym),lunas=ks.filter(k=>k.s===ST.E),bs=D.bayar.filter(b=>ld(b.tgl).slice(0,7)===ym),rev=bs.reduce((a,b)=>a+b.j,0),nd=new Date(+ym.slice(0,4),+ym.slice(5),0).getDate();
 const daily=[...Array(nd)].map((_,i)=>bs.filter(b=>+ld(b.tgl).slice(8)===i+1).reduce((a,b)=>a+b.j,0)),vis=[...Array(nd)].map((_,i)=>ks.filter(k=>+ld(k.tgl).slice(8)===i+1).length);
 const m={};lunas.forEach(k=>items(k).forEach(i=>{const x=m[i.n]||(m[i.n]={n:i.n,g:i.g,q:0,v:0});x.q+=i.q;x.v+=i.q*i.h}));
 return{ks,lunas,rev,nd,daily,vis,top:Object.values(m).sort((a,b)=>b.v-a.v),baru:D.pasien.filter(p=>p.t===U.t&&p.c&&ld(p.c).slice(0,7)===ym).length,avg:lunas.length?rev/lunas.length:0}}
const blnLabel=ym=>new Date(ym+"-01T12:00:00").toLocaleDateString("id-ID",{month:"long",year:"numeric"});
VW["Laporan Bulanan"]=()=>{const ym=S.bln||today().slice(0,7),r=rep(ym);
 return ph("MANAJER","Laporan Bulanan","Rekap kunjungan dan pendapatan per bulan. Unduh hasilnya dalam format Excel.",ib("file","Unduh Excel","p","unduhXlsx()"))
 +`<div class="card" style="display:flex;gap:24px;align-items:flex-end;flex-wrap:wrap"><label style="max-width:240px">Bulan laporan<input id="bln" type="month" value="${ym}" onchange="S.bln=this.value||'';render()"></label><p style="margin:0 0 10px">Periode: <b>${blnLabel(ym)}</b></p></div>
 <div class="stats"><div class="st"><small>Total kunjungan</small><b>${r.ks.length}</b><span class="sb">${r.lunas.length} lunas</span></div><div class="st gr"><small>Total pendapatan</small><b>${rp(r.rev)}</b></div><div class="st"><small>Rata-rata / kunjungan</small><b>${rp(r.avg)}</b></div><div class="st"><small>Pasien baru</small><b>${r.baru}</b></div></div>`
 +sec("Pendapatan harian",`<div class="pd">${barSVG(r.daily,r.daily.map((_,i)=>String(i+1).padStart(2,"0")))}</div>`)
 +sec("Layanan &amp; obat terlaris",r.top.length?tbl(["Item","Qty","Pendapatan"],r.top.map(x=>[`${esc(x.n)}<br><span class="tg ${x.g==="Layanan"?"l":"o"}">${x.g}</span>`,`<span class="mono">${x.q}</span>`,`<span class="mono">${rp(x.v)}</span>`]),""):emp("Belum ada data pada bulan ini."))};
async function unduhXlsx(){const ym=S.bln||today().slice(0,7),r=rep(ym),lb=blnLabel(ym);
 if(!window.XLSX)return toast("Pustaka Excel belum termuat, coba lagi sebentar lagi");
 let dls=null;try{dls=window.claude&&claude.use?await claude.use("downloads"):null}catch(e){}
 const wb=XLSX.utils.book_new(),A=XLSX.utils.aoa_to_sheet;
 const s1=A([["Laporan Bulanan SiKlinik"],[klinikNama()],["Periode",lb],[],["Total kunjungan",r.ks.length],["Kunjungan lunas",r.lunas.length],["Total pendapatan (Rp)",r.rev],["Rata-rata per kunjungan (Rp)",Math.round(r.avg)],["Pasien baru",r.baru]]);s1["!cols"]=[{wch:30},{wch:24}];
 const s2=A([["Tanggal","Kunjungan","Pendapatan (Rp)"],...r.daily.map((v,i)=>[(i+1)+" "+lb,r.vis[i],v]),["Total",r.vis.reduce((a,b)=>a+b,0),r.rev]]);s2["!cols"]=[{wch:24},{wch:12},{wch:18}];
 const s3=A([["Item","Kategori","Qty","Pendapatan (Rp)"],...r.top.map(x=>[x.n,x.g,x.q,x.v])]);s3["!cols"]=[{wch:36},{wch:12},{wch:8},{wch:18}];
 XLSX.utils.book_append_sheet(wb,s1,"Ringkasan");XLSX.utils.book_append_sheet(wb,s2,"Harian");XLSX.utils.book_append_sheet(wb,s3,"Item Terlaris");
 const fn="Laporan_SiKlinik_"+ym+".xlsx";
 try{if(dls)await dls.save({filename:fn,data:XLSX.write(wb,{type:"array",bookType:"xlsx"})});else XLSX.writeFile(wb,fn);lg("unduh","laporan",0);save();toast("Laporan Excel diunduh")}
 catch(e){if(!e||e.code!=="declined")toast("Gagal menyimpan file Excel")}}
/* kelola akun */
VW["Kelola Akun"]=()=>ph("MANAJER","Kelola Akun Staf","Peran menentukan menu yang terlihat (RBAC). Akun hanya berlaku di klinik ini.",ib("userplus","Akun Baru","p","akunBaru()"))
 +`<div class="card">${tbl(["Nama","Username","Email","Peran","Status","Aksi"],D.akun.filter(a=>a.t===U.t).map(a=>{const me=a.id===U.id;return[`${esc(a.n)}${me?' <small style="display:inline">(Anda)</small>':""}`,`<span class="mono">${a.u}</span>`,a.e?esc(a.e):`<button class="lnk" onclick="emailAkun(${a.id})">+ tambah email</button>`,me?`<span class="rl ${a.r}">${RL[a.r]}</span>`:`<select aria-label="Peran ${esc(a.n)}" onchange="chRole(${a.id},this.value)" style="min-width:150px">${["pendaftaran","dokter","apoteker","kasir","manajer"].map(r=>`<option value="${r}" ${r===a.r?"selected":""}>${RL[r]}</option>`).join("")}</select>`,a.on?'<span class="bg tl">Aktif</span>':'<span class="bg rs">Nonaktif</span>',me?"":`<button class="btn" onclick="togAkun(${a.id})">${a.on?"Nonaktifkan":"Aktifkan"}</button>`]}),"")}</div>`;
function chRole(id,r){find(D.akun,id).r=r;lg("ubah","peran",id);save();render();toast("Peran diperbarui")}
function togAkun(id){const a=find(D.akun,id);a.on=a.on?0:1;lg("ubah","akun",id);save();render()}
function emailAkun(id){modal("Tambah email",`<label>Email<input id="ae" type="email" placeholder="nama@klinik.id" autocapitalize="off"></label><button class="btn p fw" style="margin-top:16px" onclick="saveEmail(${id})">Simpan</button>`)}
function saveEmail(id){const e=$("#ae").value.trim();if(!/^\S+@\S+\.\S+$/.test(e))return toast("Isi email yang valid");find(D.akun,id).e=e;lg("ubah","akun",id);save();closeM();render();toast("Email disimpan")}
function akunBaru(){modal("Akun Baru",`<div class="fr" style="grid-template-columns:1fr"><label>Nama lengkap<input id="an"></label><label>Username<input id="au" class="mono" autocapitalize="off"></label><label>Email (opsional)<input id="ae" type="email"></label><label>Peran<select id="ar">${["pendaftaran","dokter","apoteker","kasir","manajer"].map(r=>`<option value="${r}">${RL[r]}</option>`).join("")}</select></label><label>Password<input id="ap" type="password"></label></div><button class="btn p fw" onclick="addAkun()">Buat akun</button>`)}
function addAkun(){const a={id:nid(D.akun),n:$("#an").value.trim(),u:$("#au").value.trim(),e:$("#ae").value.trim(),r:$("#ar").value,h:hs($("#ap").value),on:1,m:1,t:U.t};
 if(!a.n||!a.u||$("#ap").value.length<6)return toast("Isi nama, username, dan password minimal 6 karakter");
 if(D.akun.some(x=>x.t===U.t&&x.u===a.u))return toast("Username sudah dipakai");D.akun.push(a);lg("tambah","akun",a.id);save();closeM();render();toast("Akun dibuat")}

/* layanan & tarif */
const KAT=["Konsultasi","Tindakan","Laboratorium","Administrasi","Lainnya"];
VW["Layanan & Tarif"]=()=>ph("MANAJER","Layanan & Tarif","Tarif yang dipilih dokter sebagai tindakan otomatis masuk ke tagihan kasir.",ib("plus","Layanan Baru","p","layananForm(0)"))
 +`<div class="card">${tbl(["Layanan","Kategori","Tarif","Aksi"],[...D.layanan].sort((a,b)=>a.n.localeCompare(b.n)).map(l=>[esc(l.n),`<span class="tgc">${esc(l.k||"Lainnya")}</span>`,`<span class="mono">${rp(l.t)}</span>`,`<button class="btn ic" onclick="layananForm(${l.id})" aria-label="Ubah ${esc(l.n)}">${ic("edit",17)}</button> <button class="btn ic" onclick="delLay(${l.id})" aria-label="Hapus ${esc(l.n)}">${ic("trash",17)}</button>`]),"")}</div>`;
function layananForm(id){const l=id?find(D.layanan,id):{n:"",k:"Konsultasi",t:""};
 modal(id?"Ubah Layanan":"Layanan Baru",`<div class="fr" style="grid-template-columns:1fr"><label>Nama layanan<input id="ln" value="${esc(l.n)}"></label><label>Kategori<select id="lk2">${KAT.map(k=>`<option ${k===l.k?"selected":""}>${k}</option>`).join("")}</select></label><label>Tarif (Rp)<input id="lt" type="number" min="0" value="${l.t}"></label></div><button class="btn p fw" onclick="saveLay(${id})">Simpan</button>`)}
function saveLay(id){const n=$("#ln").value.trim(),t=+$("#lt").value,k=$("#lk2").value;if(!n||t<0||$("#lt").value==="")return toast("Isi nama dan tarif layanan");
 if(id){const l=find(D.layanan,id);l.n=n;l.k=k;l.t=t}else D.layanan.push({id:nid(D.layanan),n,k,t});lg(id?"ubah":"tambah","layanan",id);save();closeM();render();toast("Layanan disimpan")}
function delLay(id){const l=find(D.layanan,id);if(D.kunjungan.some(k=>k.l.includes(id)))return toast("Layanan ini sudah dipakai di kunjungan, tidak bisa dihapus");
 ask("Hapus layanan <b>"+esc(l.n)+"</b>?",()=>{D.layanan=D.layanan.filter(x=>x.id!==id);lg("hapus","layanan",id);save();closeM();render();toast("Layanan dihapus")})}

/* jadwal dokter */
VW["Jadwal Dokter"]=()=>{const ed=U.r==="manajer",dow=new Date().getDay(),dok=D.akun.filter(a=>a.r==="dokter"&&a.on&&a.t===U.t);
 return ph("JADWAL","Jadwal Praktik Dokter","Jadwal mingguan praktik dokter per poli.")
 +(ed?`<div class="card"><h3>Tambah jadwal</h3><div class="jf"><label>Dokter<select id="jd"><option value="">Pilih dokter</option>${dok.map(d=>`<option value="${d.id}">${esc(d.n)}</option>`).join("")}</select></label><label>Hari<select id="jh">${HO.map(n=>`<option value="${n}">${HN[n]}</option>`).join("")}</select></label><label>Mulai<input id="ja" type="time" value="08:00"></label><label>Selesai<input id="jb" type="time" value="14:00"></label><button class="btn p" onclick="addJ()" style="display:inline-flex;gap:8px;align-items:center;justify-content:center">${ic("plus",17)}Tambah</button></div></div>`:"")
 +`<div class="wk">${HO.map(n=>{const ss=D.jadwal.filter(s=>s.hari===n).sort((a,b)=>a.a.localeCompare(b.a));return `<div class="card" style="margin:0;${n===dow?"border:2px solid var(--bl)":""}"><div style="display:flex;justify-content:space-between;align-items:baseline"><h3>${HN[n]}</h3><small class="mono" style="display:inline">${ss.length} sesi</small></div>${ss.length?ss.map(s=>`<div class="ss"><div style="display:flex;justify-content:space-between;align-items:center;gap:8px"><b>${esc(dn(s.d))}</b>${ed?`<button class="lnk" onclick="delJ(${s.id})" aria-label="Hapus sesi">${ic("trash",16)}</button>`:""}</div><small class="mono" style="display:flex;gap:6px;align-items:center">${ic("clock",13)}${s.a}–${s.b} · ${esc(s.p||"Poli Umum")}</small></div>`).join(""):'<p class="mu" style="margin:12px 0 0">Tidak ada praktik</p>'}</div>`}).join("")}</div>`};
function addJ(){const d=+$("#jd").value,j={id:nid(D.jadwal),d,hari:+$("#jh").value,a:$("#ja").value,b:$("#jb").value,p:"Poli Umum"};
 if(!d)return toast("Pilih dokter");if(!j.a||!j.b||j.a>=j.b)return toast("Jam selesai harus setelah jam mulai");
 if(D.jadwal.some(s=>s.d===d&&s.hari===j.hari&&s.a<j.b&&j.a<s.b))return toast("Jadwal dokter ini bertabrakan");
 D.jadwal.push(j);lg("tambah","jadwal",j.id);save();render();toast("Jadwal ditambahkan")}
function delJ(id){D.jadwal=D.jadwal.filter(s=>s.id!==id);lg("hapus","jadwal",id);save();render();toast("Sesi dihapus")}

/* log akses rekam medis */
VW["Log Akses"]=()=>ph("AUDIT","Log Akses Rekam Medis","Setiap kali rekam medis dibuka, dibuat, atau dikoreksi, aksinya tercatat di sini. Isi rekam medis tetap hanya dapat dibaca dokter.")
 +`<div class="card">${tbl(["Waktu","Pengguna","Aksi","Pasien","Keterangan"],[...D.akses].sort((a,b)=>b.t.localeCompare(a.t)).slice(0,100).map(l=>[`<span class="mono" style="font-size:13px">${fdt(l.t)}</span>`,`${esc(dn(l.u))}<small>${RL[find(D.akun,l.u).r]||""}</small>`,`<span class="tgc ${l.a==="buat"?"gn":""}">${l.a}</span><small>${l.o}</small>`,esc(pn(l.p).n||"-"),esc(l.k||"")]),"Belum ada aktivitas.")}</div>`;

/* ---------- platform (Tim SiKlinik) ---------- */
const cnt=c=>({u:(c.u||0)+D.akun.filter(a=>a.t===c.c).length,ps:(c.ps||0)+D.pasien.filter(p=>p.t===c.c).length});
const pkH=n=>(D.paket.find(p=>p.n===n)||{h:0}).h;
const dlB=sd=>{const d=dl(sd);return `<span class="bg ${d<0?"rs":d<=7?"am":"tl"}">${d<0?"lewat "+(-d)+" hari":d===0?"hari ini":d+" hari lagi"}</span>`};
VW["Daftar Klinik"]=()=>{const cs=D.klinik.map(c=>({c,n:cnt(c)}));
 return ph("PORTAL ADMIN · TIM SIKLINIK","Daftar Klinik Pelanggan","Setiap klinik memiliki subdomain sendiri dan data yang terisolasi dari klinik lain.",ib("refresh","Muat Ulang Data Demo","","resetDemo()")+ib("plus","Klinik Baru","p","klinikBaru()"))
 +`<div class="stats"><div class="st"><small>Klinik</small><b>${D.klinik.length}</b></div><div class="st gr"><small>Aktif</small><b>${D.klinik.filter(c=>c.on).length}</b></div><div class="st am"><small>Jatuh tempo ≤ 7 hari</small><b>${D.klinik.filter(c=>dl(c.sd)<=7).length}</b></div><div class="st"><small>Total pasien</small><b>${cs.reduce((a,x)=>a+x.n.ps,0)}</b></div></div>
 <div class="card">${tbl(["Klinik","Paket","Langganan s/d","Pengguna / Pasien","Status","Aksi"],cs.map(({c,n})=>[`<div style="display:flex;gap:12px;align-items:center">${ic("bld",22)}<div><b>${esc(c.n)}</b><small class="mono" style="color:var(--bl)">${c.c}.siklinik.id</small></div></div>`,c.p,`${fd(c.sd)}<br>${dlB(c.sd)}`,`<span class="mono">${n.u} / ${n.ps}</span>`,c.on?'<span class="bg tl">aktif</span>':'<span class="bg rs">nonaktif</span>',`<div style="display:flex;gap:8px"><button class="btn" onclick="S={fk:${c.id}};V='Tagihan Langganan';render()">${ic("file",15)} Tagihan</button><button class="btn ic" onclick="togKlinik(${c.id})" aria-label="Aktifkan atau nonaktifkan">${ic("power",17)}</button></div>`]),"")}</div>`};
function togKlinik(id){const c=find(D.klinik,id);c.on=c.on?0:1;lg("ubah","klinik",id);save();render()}
function klinikBaru(){modal("Klinik Baru",`<div class="fr" style="grid-template-columns:1fr"><label>Nama klinik<input id="kn"></label><label>Kode (subdomain)<div class="in"><input id="kc" class="mono" autocapitalize="off" placeholder="contoh: sehat"><span class="mono sf">.siklinik.id</span></div></label><label>Paket<select id="kp">${D.paket.map(p=>`<option ${p.n==="Pro"?"selected":""}>${esc(p.n)}</option>`).join("")}</select></label></div><button class="btn p fw" onclick="addKlinik()">Tambah klinik</button><p class="mu" style="font-size:13px;margin:12px 0 0">Langganan pertama berlaku 30 hari. Akun staf dibuat saat onboarding.</p>`)}
function addKlinik(){const c={id:nid(D.klinik),n:$("#kn").value.trim(),c:$("#kc").value.trim().toLowerCase(),p:$("#kp").value,sd:fut(30),on:1,u:0,ps:0};
 if(!c.n||!/^[a-z0-9-]{3,}$/.test(c.c))return toast("Isi nama dan kode (huruf kecil, angka, minimal 3 karakter)");
 if(c.c==="siklinik"||c.c==="admin"||D.klinik.some(x=>x.c===c.c))return toast("Kode klinik sudah dipakai");
 D.klinik.push(c);D.tagL.push({id:nid(D.tagL),k:c.id,j:pkH(c.p),tempo:c.sd,lunas:0});lg("tambah","klinik",c.id);save();closeM();render();toast("Klinik ditambahkan")}
VW["Paket Langganan"]=()=>ph("PORTAL ADMIN","Paket Langganan","Paket yang dapat dipilih klinik pelanggan.",ib("plus","Paket Baru","p","paketBaru()"))
 +`<div class="pg">${D.paket.map((p,i)=>`<div class="card pk ${i===1?"pop":""}"><div class="nm">${esc(p.n)}</div><div class="pr">${rp(p.h)} <small>/bln</small></div><div class="mu">Hingga ${p.mx} pengguna</div><ul>${p.f.map(f=>`<li>${ic("check",18)}${esc(f)}</li>`).join("")}</ul></div>`).join("")}</div>`;
function paketBaru(){modal("Paket Baru",`<div class="fr" style="grid-template-columns:1fr"><label>Nama paket<input id="pkn"></label><label>Harga per bulan (Rp)<input id="pkh" type="number" min="0"></label><label>Maksimal pengguna<input id="pkm" type="number" min="1"></label><label>Fitur (satu per baris)<textarea id="pkf"></textarea></label></div><button class="btn p fw" onclick="addPaket()">Simpan paket</button>`)}
function addPaket(){const p={id:nid(D.paket),n:$("#pkn").value.trim(),h:+$("#pkh").value,mx:+$("#pkm").value,f:$("#pkf").value.split("\n").map(x=>x.trim()).filter(Boolean)};
 if(!p.n||p.h<=0||p.mx<1||!p.f.length)return toast("Lengkapi nama, harga, batas pengguna, dan fitur");D.paket.push(p);lg("tambah","paket",p.id);save();closeM();render();toast("Paket ditambahkan")}
VW["Tagihan Langganan"]=()=>{const fk=S.fk,l=D.tagL.filter(t=>!fk||t.k===fk).sort((a,b)=>a.tempo.localeCompare(b.tempo));
 return ph("PORTAL ADMIN","Tagihan Langganan","Tagihan bulanan klinik pelanggan. Menandai lunas memperpanjang langganan 30 hari.",fk?`<button class="btn" onclick="S={};render()">Tampilkan semua klinik</button>`:"")
 +`<div class="card">${tbl(["No. Tagihan","Klinik","Periode","Jumlah","Jatuh tempo","Status",""],l.map(t=>{const c=find(D.klinik,t.k);return[`<span class="mono">INV-${String(t.id).padStart(4,"0")}</span>`,`<b>${esc(c.n)}</b><small class="mono">${c.p}</small>`,new Date(t.tempo).toLocaleDateString("id-ID",{month:"long",year:"numeric"}),`<span class="mono">${rp(t.j)}</span>`,t.lunas?fd(t.tempo):`${fd(t.tempo)}<br>${dlB(t.tempo)}`,t.lunas?'<span class="bg tl">Lunas</span>':'<span class="bg rs">Belum bayar</span>',t.lunas?"":`<button class="btn p" onclick="lunas(${t.id})">Tandai lunas</button>`]}),"Belum ada tagihan.")}</div>`};
function lunas(id){const t=find(D.tagL,id),c=find(D.klinik,t.k);t.lunas=1;const b=dl(c.sd)>0?c.sd:today();c.sd=ld(new Date(b).getTime()+30*864e5);
 D.tagL.push({id:nid(D.tagL),k:c.id,j:pkH(c.p),tempo:c.sd,lunas:0});lg("ubah","tagihan_langganan",id);save();render();toast("Lunas. Langganan "+c.c+" diperpanjang sampai "+fd(c.sd))}
const CONTOH="nama,nik,tgl_lahir,jk,alamat,telp\nMaya Sari,1571010101900011,1990-01-01,P,Telanaipura Jambi,081300000011\nBudi Hartono,1571010202850012,1985-02-02,L,Kotabaru Jambi,081300000012\nDewi Lestari,1571010303920013,1992-03-03,P,Jelutung Jambi,081300000013";
VW["Impor Data Pasien"]=()=>ph("PORTAL ADMIN","Impor Data Pasien","Pindahkan data pasien lama klinik ke SiKlinik dalam format CSV.")
 +`<div class="g2"><div class="card"><div class="fr" style="grid-template-columns:1fr"><label>Klinik tujuan<select id="ik">${D.klinik.map(c=>`<option value="${c.c}" ${c.c==="terpadu"?"selected":""}>${esc(c.n)}</option>`).join("")}</select></label><label>Data CSV<textarea id="icsv" class="mono" style="min-height:190px;font-size:13px" placeholder="nama,nik,tgl_lahir,jk,alamat,telp"></textarea></label></div><button class="btn p" onclick="impor()">${ic("cloud",16)} Impor data</button> <button class="btn" onclick="$('#icsv').value=CONTOH">Isi contoh</button></div>
 <div class="card"><h3>Format kolom</h3><p class="mu" style="margin:8px 0 12px;text-align:left;padding:0">Satu pasien per baris, dipisah koma.</p><ul class="gd"><li><span class="mono">nama</span>: nama lengkap</li><li><span class="mono">nik</span>: 16 digit, dipakai untuk cek duplikat</li><li><span class="mono">tgl_lahir</span>: YYYY-MM-DD</li><li><span class="mono">jk</span>: L atau P</li><li><span class="mono">alamat</span>, <span class="mono">telp</span>: bebas</li></ul><div id="ihasil" style="margin-top:16px"></div></div></div>`;
function impor(){const t=$("#ik").value,ln=$("#icsv").value.split("\n").map(x=>x.trim()).filter(Boolean);let ok=0,sk=[];
 ln.forEach((x,i)=>{const c=x.split(",").map(y=>y.trim());if(i===0&&c[0].toLowerCase()==="nama")return;
  const p={n:c[0],nik:c[1],l:c[2],jk:(c[3]||"").toUpperCase(),al:c[4]||"",tl:c[5]||""};
  if(!p.n||!/^\d{16}$/.test(p.nik||"")||!/^\d{4}-\d{2}-\d{2}$/.test(p.l||"")||!["L","P"].includes(p.jk))return sk.push("Baris "+(i+1)+": format tidak valid");
  if(D.pasien.some(y=>y.t===t&&y.nik===p.nik))return sk.push("Baris "+(i+1)+": NIK sudah terdaftar");
  mkP(p,t);ok++});
 if(ok){lg("tambah","impor_pasien",ok);save()}
 $("#ihasil").innerHTML=`<div class="al ${ok?"g":"r"}" style="margin:0">${ic(ok?"ccheck":"alert",20)}<span><b>${ok} berhasil</b>, ${sk.length} dilewati${sk.length?"<br>"+sk.slice(0,5).map(esc).join("<br>"):""}</span></div>`;toast(ok+" pasien diimpor")}

/* ---------- INIT APP (Database Sync) ---------- */
async function initApp() {
    const app = $("#app");
    app.innerHTML = '<div style="display:flex;justify-content:center;align-items:center;height:100vh;font-family:sans-serif;color:#5f7384"><div style="text-align:center"><div style="font-size:24px;margin-bottom:10px;font-weight:bold;color:#0b7a5e">SiKlinik</div>Menghubungkan ke Database Server...</div></div>';
    
    try {
        const res = await fetch('/api/sync');
        const data = await res.json();
        D = data || seed();
        
        // Jika database masih kosong, simpan data seed ke database
        if (!data) {
            await fetch('/api/sync', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(D)
            });
        }
    } catch (e) {
        console.error("Gagal konek ke server, menggunakan data lokal sementara", e);
        D = seed(); 
    }
    
    // Render aplikasi setelah data siap
    render();
}

initApp();