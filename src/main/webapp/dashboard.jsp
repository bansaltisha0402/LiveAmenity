<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.liveamenity.model.Facility" %>
<%@ page import="com.liveamenity.model.User" %>
<%@ page import="com.liveamenity.service.RecommendationService" %>
<%
    User user = (User) session.getAttribute("user");
    List<Facility> facilities = (List<Facility>) request.getAttribute("facilities");
    List<Facility> recommendedFacilities = (List<Facility>) request.getAttribute("recommendedFacilities");
    String selectedActivity = (String) request.getAttribute("selectedActivity");
    if (selectedActivity == null) selectedActivity = "";
    Facility preferredFacility = (Facility) request.getAttribute("preferredFacility");
    Boolean preferredFacilityFullValue = (Boolean) request.getAttribute("preferredFacilityFull");
    Boolean preferredFacilityBusyValue = (Boolean) request.getAttribute("preferredFacilityBusy");
    boolean preferredFacilityFull = Boolean.TRUE.equals(preferredFacilityFullValue);
    boolean preferredFacilityBusy = Boolean.TRUE.equals(preferredFacilityBusyValue);
    String recommendationMessage = (String) request.getAttribute("recommendationMessage");
    if (user == null) { response.sendRedirect("index.jsp"); return; }
    String displayName = "Resident";
    try { if (user.getName() != null && !user.getName().trim().isEmpty()) displayName = user.getName().trim(); } catch (Exception ignored) {}
    int total = facilities == null ? 0 : facilities.size(), available = 0, occupied = 0, capacity = 0;
    if (facilities != null) for (Facility f : facilities) {
        occupied += f.getOccupancy(); capacity += f.getCapacity();
        if (f.isAvailable()) available++;
    }
    int occupancyPct = capacity == 0 ? 0 : (int)Math.round(occupied * 100.0 / capacity);
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>LiveAmenity | Your Community, Better</title>
<style>
:root{--purple:#5338e9;--purple2:#3e27c4;--ink:#17172e;--muted:#74758f;--line:#e8e6f6;--paper:#fff;--page:#f8f8ff;--mint:#dff8ee;--green:#078361;--shadow:0 14px 38px rgba(55,42,150,.08)}
*{box-sizing:border-box;margin:0;padding:0}
html{scroll-behavior:smooth;scroll-padding-top:78px}
body{font-family:Inter,"Segoe UI",Arial,sans-serif;background:var(--page);color:var(--ink);font-size:14px;line-height:1.55}
a{color:inherit;text-decoration:none}button,input{font:inherit}button{cursor:pointer}
.topbar{height:72px;position:sticky;top:0;z-index:100;background:#ffffffed;backdrop-filter:blur(18px);border-bottom:1px solid var(--line);display:flex;align-items:center;padding:0 clamp(16px,3vw,48px);gap:18px}
.brand{display:flex;align-items:center;gap:10px;font-size:22px;font-weight:900;letter-spacing:-.8px;white-space:nowrap}
.brand-mark{width:39px;height:39px;border-radius:13px;display:grid;place-items:center;background:linear-gradient(145deg,#715bff,#4328d1);color:white;font-size:20px;box-shadow:0 8px 20px #5338e92d}
.brand-name span{color:var(--purple)}
.topnav{display:flex;gap:5px;margin-left:25px}
.topnav a{font-size:12px;font-weight:750;color:#666781;padding:10px 12px;border-radius:10px;transition:.2s}
.topnav a:hover,.topnav a.active{background:#efedff;color:var(--purple)}
.top-right{display:flex;align-items:center;gap:10px;margin-left:auto}
.top-search{width:240px;height:39px;border:1px solid #e3e1f1;background:#fafaff;border-radius:22px;display:flex;align-items:center;gap:8px;padding:0 13px}
.top-search svg{width:16px;color:#8a8ba6}.top-search input{border:0;outline:0;background:transparent;width:100%;font-size:11px;min-width:0}
.avatar{width:30px;height:30px;border-radius:50%;background:var(--purple);color:white;display:grid;place-items:center;font-size:12px;font-weight:850}
.profile{display:flex;align-items:center;gap:8px;border:1px solid var(--line);background:white;padding:4px 11px 4px 5px;border-radius:25px;font-size:11px;font-weight:750;white-space:nowrap}
.layout{display:grid;grid-template-columns:190px minmax(0,1fr);min-height:calc(100vh - 72px)}
.sidebar{position:sticky;top:72px;height:calc(100vh - 72px);background:white;border-right:1px solid var(--line);padding:24px 13px 15px;display:flex;flex-direction:column}
.side-caption{padding:0 12px 12px;font-size:9px;letter-spacing:1.5px;font-weight:900;color:#a1a1b6}
.side-links{display:grid;gap:5px}.side-links a{display:flex;align-items:center;gap:11px;padding:12px 13px;border-radius:11px;color:#686984;font-size:12px;font-weight:750;transition:.2s}
.side-links a .side-icon{width:19px;text-align:center;font-size:17px;color:#7865ed}
.side-links a:hover,.side-links a.active{background:#eeebff;color:var(--purple)}
.sidebar-bottom{margin-top:auto}
.sidebar-promo{padding:15px 12px 0;background:linear-gradient(150deg,#f0edff,#e2e1ff);border-radius:16px;overflow:hidden}
.sidebar-promo strong{font-size:12px;line-height:1.3;display:block}.sidebar-promo p{font-size:10px;color:#777894;margin-top:6px}
.sidebar-promo img{width:100%;height:85px;object-fit:cover;object-position:center 62%;mix-blend-mode:normal;border-radius:10px;margin-top:4px}
.side-account{border-top:1px solid var(--line);margin-top:14px;padding:14px 3px 0;display:flex;gap:9px;align-items:center;font-size:11px;font-weight:800}.side-account small{display:block;font-weight:500;color:#85869c;font-size:10px}
main{min-width:0}
.section{padding:clamp(24px,3vw,42px) clamp(16px,2.5vw,38px);scroll-margin-top:72px}
.hero-section{min-height:calc(100vh - 72px);display:flex;align-items:center;background:radial-gradient(ellipse at 90% 8%,#ebe8ff 0,transparent 40%),linear-gradient(180deg,#f9f8ff,#f3f2ff);padding-top:38px;padding-bottom:42px}
.hero-grid{display:grid;grid-template-columns:minmax(0,1.45fr) minmax(280px,.75fr);gap:20px;width:100%;max-width:1600px;margin:auto}
.hero-card{min-height:420px;position:relative;overflow:hidden;border-radius:28px;background:linear-gradient(112deg,#e7e3ff 0%,#dcd9ff 57%,#d3d1ff 100%);padding:clamp(28px,4vw,58px);display:flex;align-items:center;box-shadow:var(--shadow)}
.hero-card:before{content:"";position:absolute;width:420px;height:420px;border:1px solid #fff8;border-radius:50%;right:-90px;top:-230px}
.hero-copy{position:relative;z-index:2;width:57%}
.eyebrow{display:flex;align-items:center;gap:8px;font-size:10px;letter-spacing:1.7px;text-transform:uppercase;font-weight:900;color:var(--purple)}
.eyebrow:before{content:"";width:7px;height:7px;border-radius:50%;background:var(--purple)}
.hero h1{font-size:clamp(38px,4vw,66px);line-height:1.02;letter-spacing:-2.2px;margin-top:19px}
.hero h1 span{color:var(--purple)}
.hero p{max-width:430px;font-size:15px;color:#626584;line-height:1.75;margin-top:18px}
.btn-row{display:flex;flex-wrap:wrap;gap:11px;margin-top:25px}
.btn{border:0;border-radius:12px;padding:13px 18px;font-size:12px;font-weight:850;display:inline-flex;align-items:center;justify-content:center;gap:10px;transition:transform .2s,box-shadow .2s}
.btn:hover{transform:translateY(-3px);box-shadow:0 10px 20px #3f2ac62b}
.btn-primary{color:#fff;background:linear-gradient(110deg,#6d50ff,#452bd3);box-shadow:0 8px 18px #5338e92b}
.btn-light{background:#fff;color:#272341;border:1px solid #e5e2fa}
.btn svg{width:16px;height:16px}
.hero-art{position:absolute;width:53%;right:-2%;bottom:4%;max-height:82%;object-fit:cover;mix-blend-mode:normal;border-radius:18px;filter:drop-shadow(0 14px 12px #3e2dc41a);animation:float 6s ease-in-out infinite}
.hero-tags{display:flex;gap:15px;flex-wrap:wrap;margin-top:25px;color:#5c5e7d;font-size:11px;font-weight:750}
.hero-tags span{display:flex;align-items:center;gap:7px}.hero-tags b{color:var(--purple);font-size:15px}
.stats-panel{border-radius:26px;padding:23px;background:#fff;border:1px solid #eeecfb;box-shadow:var(--shadow);display:flex;flex-direction:column;justify-content:center}
.panel-kicker{display:flex;justify-content:space-between;align-items:center;font-size:14px;font-weight:900;margin-bottom:17px}
.live-dot{font-size:10px;color:#0b936d;background:#e4faf1;border-radius:20px;padding:6px 9px}
.stats-grid{display:grid;grid-template-columns:1fr 1fr;gap:12px}
.stat-card{border:1px solid #efedf8;background:linear-gradient(150deg,#fff,#faf9ff);border-radius:16px;padding:16px 13px;min-height:116px}
.stat-icon{width:35px;height:35px;border-radius:11px;background:#eeebff;color:var(--purple);display:grid;place-items:center;font-size:19px;margin-bottom:12px}
.stat-card strong{font-size:28px;letter-spacing:-1px;display:block;line-height:1.15}
.stat-card span{display:block;font-size:11px;color:var(--muted);margin-top:4px}
.occupancy-overview{margin-top:17px;padding:15px;border-radius:15px;background:#f6f4ff}
.occupancy-overview div:first-child{display:flex;justify-content:space-between;gap:8px;font-size:11px;font-weight:800}
.track{height:8px;border-radius:20px;background:#e5e2f7;overflow:hidden;margin-top:10px}.track span{display:block;height:100%;width:var(--fill);border-radius:20px;background:linear-gradient(90deg,#7258ff,#a69aff);animation:fillBar 1.2s ease both}
.section-heading{display:flex;justify-content:space-between;align-items:end;gap:20px;margin-bottom:23px}
.section-heading h2{font-size:clamp(27px,2.7vw,42px);letter-spacing:-1.3px;line-height:1.12;margin-top:8px}
.section-heading p{font-size:13px;color:var(--muted);margin-top:7px}
.section-heading .eyebrow{font-size:10px}
.facilities-section{min-height:100vh;background:#fff}
.filters{display:flex;gap:8px;flex-wrap:wrap;margin:0 0 20px}
.filter-btn{border:1px solid #e7e4f6;background:#fff;color:#74758f;padding:9px 16px;border-radius:22px;font-size:11px;font-weight:800;transition:.2s}
.filter-btn.active,.filter-btn:hover{background:var(--purple);border-color:var(--purple);color:#fff}
.facility-grid{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:18px}
.facility-card{min-width:0;overflow:hidden;background:#fff;border:1px solid #e9e7f6;border-radius:21px;box-shadow:0 8px 25px #2b1b6b09;transition:transform .25s,box-shadow .25s;animation:rise .5s both}
.facility-card:hover{transform:translateY(-7px);box-shadow:0 20px 35px #2b1b6b15}
.facility-card[hidden]{display:none}
.facility-image{height:220px;position:relative;overflow:hidden;display:grid;place-items:center}
.facility-image img{width:100%;height:100%;object-fit:cover;transition:transform .45s}
.facility-card:hover .facility-image img{transform:scale(1.06)}
.facility-image.gym{background:#e8e3ff}.facility-image.court{background:#d8f7ed}.facility-image.study{background:#fff0df}.facility-image.pool{background:#dff3ff}.facility-image.yoga{background:#f7e6ff}.facility-image.common{background:#e9e7ff}
.facility-label{position:absolute;left:15px;top:15px;background:#ffffffed;color:var(--purple);border-radius:20px;padding:7px 11px;font-size:10px;font-weight:900;box-shadow:0 4px 12px #251b5a12}
.facility-open{position:absolute;right:14px;bottom:14px;width:41px;height:41px;border:0;border-radius:50%;background:var(--purple);color:#fff;font-size:22px;box-shadow:0 7px 15px #5338e945;transition:.2s}
.facility-open:hover{transform:rotate(45deg) scale(1.06)}
.facility-info{padding:17px 18px 18px}
.facility-title-row{display:flex;justify-content:space-between;gap:10px;align-items:start}
.facility-info h3{font-size:18px;letter-spacing:-.4px}
.facility-info p{font-size:12px;color:var(--muted);margin-top:4px}
.status{font-size:10px;font-weight:850;padding:6px 9px;border-radius:20px;white-space:nowrap}
.status.available{background:#dff9ef;color:#087d5d}.status.busy{background:#fff1d5;color:#a26b0b}.status.full{background:#ffe4e7;color:#b42c47}
.facility-bottom{display:flex;align-items:center;justify-content:space-between;gap:10px;margin-top:16px;padding-top:13px;border-top:1px solid #f0eef8}
.facility-bottom small{font-size:11px;color:var(--muted)}.facility-bottom strong{color:#393354}
.small-book{border:0;border-radius:10px;background:#f0edff;color:var(--purple);padding:9px 13px;font-size:11px;font-weight:850;transition:.2s}
.small-book:hover{background:var(--purple);color:#fff}
.availability-section{min-height:90vh;background:linear-gradient(160deg,#f5f3ff,#fff 70%);display:flex;flex-direction:column;justify-content:center}
.availability-layout{display:grid;grid-template-columns:minmax(0,1.15fr) minmax(280px,.85fr);gap:20px}
.availability-list{display:grid;gap:12px}
.availability-item{display:grid;grid-template-columns:60px minmax(0,1fr) 65px;gap:14px;align-items:center;background:#fff;border:1px solid var(--line);border-radius:17px;padding:15px;box-shadow:0 5px 17px #35267808}
.availability-thumb{width:60px;height:60px;border-radius:13px;overflow:hidden;background:#eeeaff}
.availability-thumb img{width:100%;height:100%;object-fit:cover}
.availability-name{font-size:13px;font-weight:900}.availability-sub{font-size:11px;color:var(--muted);margin-top:3px}
.availability-item .track{height:6px;margin-top:9px}
.capacity{font-size:13px;font-weight:900;text-align:right}.capacity small{display:block;font-size:10px;color:var(--muted);font-weight:600}
.insight-card{border-radius:24px;background:linear-gradient(145deg,#e6e1ff,#d4d0ff);padding:25px;position:relative;overflow:hidden;display:flex;flex-direction:column;justify-content:space-between;min-height:390px}
.insight-card h3{font-size:27px;line-height:1.12;letter-spacing:-.8px;max-width:290px}
.insight-card p{font-size:13px;color:#636185;max-width:300px;margin-top:10px}
.insight-card img{width:100%;height:190px;object-fit:contain;mix-blend-mode:multiply;margin-top:10px}
.insight-number{font-size:64px;font-weight:950;letter-spacing:-3px;color:var(--purple);line-height:1}
.how-section{min-height:75vh;background:#fff;display:flex;flex-direction:column;justify-content:center}
.feature-grid{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:17px}
.feature-card{background:#faf9ff;border:1px solid #e9e6f8;border-radius:21px;padding:25px;min-height:215px;transition:.25s}
.feature-card:hover{transform:translateY(-5px);background:#f1eeff;box-shadow:var(--shadow)}
.feature-number{width:46px;height:46px;display:grid;place-items:center;background:#e9e5ff;color:var(--purple);border-radius:15px;font-size:22px;font-weight:900}
.feature-card h3{font-size:18px;margin-top:20px;letter-spacing:-.4px}.feature-card p{font-size:12px;color:var(--muted);margin-top:7px;max-width:300px}
.steps{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:12px;margin-top:22px}
.step{background:#fff;border:1px solid var(--line);border-radius:16px;padding:15px;display:flex;align-items:center;gap:12px}
.step b{width:34px;height:34px;border-radius:50%;background:var(--purple);color:#fff;display:grid;place-items:center;flex-shrink:0}
.step strong{font-size:12px;display:block}.step span{font-size:10px;color:var(--muted);display:block;margin-top:3px}
.visits-section{min-height:85vh;background:#f5f3ff;display:flex;flex-direction:column;justify-content:center}
.visit-layout{display:grid;grid-template-columns:minmax(0,1.15fr) minmax(300px,.85fr);gap:20px}
.visit-panel{background:#fff;border:1px solid var(--line);border-radius:22px;overflow:hidden;box-shadow:var(--shadow)}
.panel-head{display:flex;justify-content:space-between;align-items:center;gap:10px;padding:20px 22px;border-bottom:1px solid #efedf8}
.panel-head h3{font-size:17px}.panel-head p{font-size:11px;color:var(--muted);margin-top:3px}
.visit-empty{padding:34px 24px;text-align:center}
.empty-icon{width:68px;height:68px;border-radius:22px;background:#efecff;color:var(--purple);display:grid;place-items:center;font-size:30px;margin:0 auto 14px}
.visit-empty h4{font-size:17px}.visit-empty p{font-size:12px;color:var(--muted);margin:6px auto 17px;max-width:300px}
.visit-actions{display:grid;gap:12px}
.visit-action{background:#fff;border:1px solid var(--line);border-radius:18px;padding:18px;display:flex;align-items:center;gap:13px}
.visit-action .action-icon{width:45px;height:45px;display:grid;place-items:center;border-radius:14px;background:#efecff;color:var(--purple);font-size:21px;flex-shrink:0}
.visit-action h4{font-size:13px}.visit-action p{font-size:10px;color:var(--muted);margin-top:3px}
.visit-action button{margin-left:auto;flex-shrink:0}
.closing-banner{margin:0 clamp(16px,2.5vw,38px) 35px;min-height:230px;border-radius:25px;overflow:hidden;position:relative;display:flex;align-items:center;padding:clamp(25px,4vw,48px);background:linear-gradient(100deg,#5032dc,#6a50f2 54%,#b5adff);color:#fff}
.closing-banner h2{font-size:clamp(28px,3vw,43px);letter-spacing:-1.2px;line-height:1.1;max-width:560px}
.closing-banner p{font-size:13px;color:#e7e1ff;margin-top:10px;max-width:480px}
.closing-banner .btn{background:#fff;color:var(--purple);margin-top:18px}
.closing-art{position:absolute;right:0;bottom:0;height:100%;width:47%;object-fit:cover;object-position:center 54%;mix-blend-mode:normal;opacity:.22}
.footer{display:flex;justify-content:space-between;gap:15px;padding:20px clamp(16px,2.5vw,38px);font-size:10px;color:#85859d;border-top:1px solid var(--line);background:#fff}
.modal-bg{display:none;position:fixed;inset:0;z-index:200;background:#1b164b75;backdrop-filter:blur(6px);align-items:center;justify-content:center;padding:18px}
.modal-bg.open{display:flex;animation:fade .18s ease}
.modal{width:min(470px,100%);background:#fff;border-radius:23px;box-shadow:0 30px 90px #20164c44;overflow:hidden;animation:rise .25s ease}
.modal-head{display:flex;align-items:start;justify-content:space-between;padding:22px 24px;border-bottom:1px solid var(--line)}
.modal-head h2{font-size:24px;letter-spacing:-.7px;margin-top:6px}.close{width:34px;height:34px;border:1px solid var(--line);background:#fff;border-radius:10px;font-size:22px;color:#777}
.modal-body{padding:22px 24px 24px}.modal-body p{font-size:12px;color:var(--muted);margin:12px 0}
.selected-facility{display:flex;align-items:center;gap:13px;background:#f3f0ff;border-radius:15px;padding:13px}
.selected-facility img{width:70px;height:58px;object-fit:cover;border-radius:10px}.selected-facility strong{display:block;font-size:14px}.selected-facility small{display:block;color:var(--muted);font-size:10px;margin-top:4px}
.modal-actions{display:flex;justify-content:flex-end;gap:9px;margin-top:20px}
.secondary{border:1px solid var(--line);background:#fff;color:var(--ink);border-radius:11px;padding:11px 15px;font-size:11px;font-weight:800}
.form-row{display:flex;gap:9px}.form-input{width:100%;min-width:0;height:44px;border:1px solid var(--line);border-radius:11px;padding:0 12px;margin-top:8px;outline:0;font-size:12px}.form-input:focus{border-color:#9b8cff;box-shadow:0 0 0 3px #5338e915}
.toast{position:fixed;right:22px;bottom:22px;z-index:300;padding:13px 17px;background:#241952;color:white;border-radius:12px;box-shadow:var(--shadow);font-size:12px;opacity:0;transform:translateY(10px);pointer-events:none;transition:.25s}.toast.show{opacity:1;transform:translateY(0)}
@keyframes rise{from{opacity:0;transform:translateY(14px)}to{opacity:1;transform:translateY(0)}}
@keyframes float{0%,100%{transform:translateY(0)}50%{transform:translateY(-10px)}}
@keyframes fillBar{from{width:0}to{width:var(--fill)}}
@keyframes fade{from{opacity:0}to{opacity:1}}
@media(min-width:1500px){.facility-grid{grid-template-columns:repeat(3,minmax(0,1fr))}.facility-image{height:255px}.hero-card{min-height:490px}.stat-card{min-height:135px}}
@media(max-width:1200px){.layout{grid-template-columns:160px minmax(0,1fr)}.topnav{margin-left:5px}.topnav a{padding:9px 8px}.facility-grid{grid-template-columns:repeat(2,minmax(0,1fr))}.hero-grid{grid-template-columns:minmax(0,1.3fr) minmax(250px,.7fr)}.hero-card{min-height:390px}.hero-copy{width:65%}.hero-art{width:48%}.facility-image{height:190px}}
@media(max-width:850px){.topnav{display:none}.layout{grid-template-columns:1fr}.sidebar{position:static;height:auto;padding:8px 10px;border-right:0;border-bottom:1px solid var(--line)}.side-caption,.sidebar-bottom{display:none}.side-links{display:flex;overflow-x:auto}.side-links a{white-space:nowrap;padding:9px 11px}.side-links a .side-icon{font-size:14px}.hero-section{min-height:auto}.hero-grid{grid-template-columns:1fr}.hero-card{min-height:390px}.stats-panel{padding:18px}.stat-card{min-height:100px}.availability-layout,.visit-layout{grid-template-columns:1fr}.insight-card{min-height:300px}.insight-card img{height:150px}.closing-art{opacity:.35;width:55%}.section{padding:28px 18px}}
@media(max-width:560px){.topbar{height:62px;padding:0 12px}.brand{font-size:18px}.brand-mark{width:32px;height:32px}.top-search{display:none}.profile{font-size:0;padding:3px}.profile .avatar{font-size:11px}.layout{min-height:calc(100vh - 62px)}.sidebar{padding:7px}.side-links{gap:2px}.side-links a{font-size:10px;padding:8px}.hero-card{min-height:510px;padding:25px;align-items:flex-start}.hero-copy{width:100%}.hero h1{font-size:42px;max-width:380px}.hero p{font-size:13px;max-width:350px}.hero-art{width:85%;height:230px;right:-1%;bottom:0;object-fit:contain;object-position:center bottom}.hero-tags{margin-top:17px;gap:9px}.stats-grid{gap:8px}.stat-card{padding:12px;min-height:100px}.stat-card strong{font-size:24px}.section-heading{align-items:start;flex-direction:column}.section-heading h2{font-size:30px}.facility-grid{grid-template-columns:1fr}.facility-image{height:220px}.facility-info h3{font-size:17px}.availability-item{grid-template-columns:50px minmax(0,1fr) 50px;gap:10px;padding:12px}.availability-thumb{width:50px;height:50px}.feature-grid,.steps{grid-template-columns:1fr}.feature-card{min-height:175px}.feature-card h3{margin-top:13px}.closing-banner{min-height:270px;margin:0 12px 22px;align-items:flex-start;padding:25px}.closing-banner h2{font-size:30px;max-width:300px}.closing-art{width:85%;height:55%;opacity:.24}.footer{flex-direction:column}.form-row{flex-direction:column}.section{padding:25px 13px}}
@media(prefers-reduced-motion:reduce){*,*:before,*:after{animation:none!important;transition:none!important;scroll-behavior:auto!important}}

/* ===== LiveAmenity visual scale and whitespace refinement ===== */
body{font-size:16px;line-height:1.65}
.topbar{height:78px;padding-left:clamp(20px,3.5vw,58px);padding-right:clamp(20px,3.5vw,58px)}
.brand{font-size:25px;gap:12px}.brand-mark{width:44px;height:44px;border-radius:14px;font-size:22px}
.topnav a{font-size:13px;padding:11px 13px}
.top-search{height:43px;width:270px}.top-search input{font-size:13px}
.profile{font-size:12px}
.layout{grid-template-columns:205px minmax(0,1fr);min-height:calc(100vh - 78px)}
.sidebar{top:78px;height:calc(100vh - 78px);padding:28px 14px 18px}
.side-links a{font-size:13px;padding:13px 14px}
.side-caption{font-size:10px}
.sidebar-promo strong{font-size:14px}.sidebar-promo p{font-size:11px}.sidebar-promo img{height:105px}
.side-account{font-size:12px}.side-account small{font-size:11px}
.section{padding:clamp(36px,4vw,62px) clamp(20px,3vw,48px);scroll-margin-top:78px}
.hero-section{min-height:calc(100vh - 78px);padding-top:30px;padding-bottom:30px}
.hero-grid{gap:24px}
.hero-card{min-height:540px;border-radius:30px;padding:clamp(34px,4vw,62px)}
.hero-copy{width:59%}
.eyebrow{font-size:11px;letter-spacing:1.8px}
.hero h1{font-size:clamp(46px,4.6vw,76px);line-height:1.02;letter-spacing:-2.6px;margin-top:22px}
.hero p{font-size:17px;line-height:1.8;margin-top:22px}
.btn{font-size:13px;padding:15px 21px;border-radius:13px}
.hero-tags{font-size:12px;gap:17px;margin-top:30px}
.hero-tags b{font-size:17px}
.stats-panel{padding:27px;border-radius:27px}
.panel-kicker{font-size:17px;margin-bottom:20px}
.live-dot{font-size:11px;padding:7px 11px}
.stats-grid{gap:14px}
.stat-card{padding:19px 16px;min-height:132px;border-radius:18px}
.stat-icon{width:41px;height:41px;border-radius:13px;font-size:21px;margin-bottom:14px}
.stat-card strong{font-size:34px}.stat-card span{font-size:12px}
.occupancy-overview{margin-top:20px;padding:17px;border-radius:17px}
.occupancy-overview div:first-child{font-size:12px}.track{height:9px}
.section-heading{margin-bottom:30px;gap:24px}
.section-heading h2{font-size:clamp(34px,3.1vw,48px);letter-spacing:-1.5px;margin-top:10px}
.section-heading p{font-size:15px;line-height:1.7;margin-top:10px}
.section-heading .eyebrow{font-size:11px}
.facilities-section{min-height:auto}
.filters{gap:10px;margin-bottom:25px}
.filter-btn{font-size:13px;padding:11px 18px}
.facility-grid{gap:23px}
.facility-card{border-radius:23px}
.facility-image{height:clamp(220px,19vw,310px)}
.facility-label{font-size:12px;padding:8px 12px}
.facility-open{width:46px;height:46px;font-size:25px}
.facility-info{padding:22px 22px 23px}
.facility-info h3{font-size:22px;letter-spacing:-.5px}
.facility-info p{font-size:14px;margin-top:5px}
.status{font-size:11px;padding:7px 10px}
.facility-bottom{margin-top:20px;padding-top:16px}
.facility-bottom small{font-size:13px}
.small-book{font-size:12px;padding:11px 15px;border-radius:11px}
.availability-section,.how-section,.visits-section{min-height:auto;justify-content:flex-start}
.availability-layout{gap:24px}
.availability-list{gap:15px}
.availability-item{grid-template-columns:76px minmax(0,1fr) 78px;gap:17px;padding:19px;border-radius:20px}
.availability-thumb{width:76px;height:76px;border-radius:16px}
.availability-name{font-size:16px}.availability-sub{font-size:13px;margin-top:5px}
.availability-item .track{height:8px;margin-top:12px}
.capacity{font-size:16px}.capacity small{font-size:11px}
.insight-card{min-height:470px;padding:30px;border-radius:27px}
.insight-card h3{font-size:34px;line-height:1.13;max-width:350px}
.insight-card p{font-size:15px;line-height:1.7;max-width:360px;margin-top:13px}
.insight-card img{height:220px}
.insight-number{font-size:78px}
.feature-grid{gap:22px}
.feature-card{padding:30px;min-height:250px;border-radius:23px}
.feature-number{width:54px;height:54px;border-radius:17px;font-size:25px}
.feature-card h3{font-size:22px;margin-top:24px}
.feature-card p{font-size:14px;line-height:1.75;margin-top:10px}
.steps{gap:16px;margin-top:28px}
.step{padding:18px;border-radius:18px;gap:14px}
.step b{width:40px;height:40px;font-size:15px}
.step strong{font-size:14px}.step span{font-size:12px;line-height:1.5}
.visit-layout{gap:24px}
.visit-panel{border-radius:24px}
.panel-head{padding:24px 26px}.panel-head h3{font-size:21px}.panel-head p{font-size:13px}
.visit-empty{padding:44px 28px}
.empty-icon{width:78px;height:78px;font-size:34px;margin-bottom:18px}
.visit-empty h4{font-size:21px}.visit-empty p{font-size:14px;line-height:1.7;margin:9px auto 22px}
.visit-action{padding:22px;gap:16px;border-radius:20px}
.visit-action .action-icon{width:52px;height:52px;border-radius:16px;font-size:24px}
.visit-action h4{font-size:16px}.visit-action p{font-size:12px;line-height:1.6;margin-top:5px}
.closing-banner{min-height:300px;margin:0 clamp(20px,3vw,48px) 40px;border-radius:29px;padding:clamp(32px,4vw,58px)}
.closing-banner h2{font-size:clamp(36px,3.6vw,52px);line-height:1.08}
.closing-banner p{font-size:15px;line-height:1.7;margin-top:14px}
.footer{padding:24px clamp(20px,3vw,48px);font-size:12px}
.modal{border-radius:26px}.modal-head{padding:26px 28px}.modal-head h2{font-size:29px}
.modal-body{padding:26px 28px 28px}.modal-body p{font-size:14px;line-height:1.7}
.form-input{height:49px;font-size:14px}
.secondary{font-size:13px;padding:13px 17px}
.toast{font-size:14px;padding:15px 19px}
@media(min-width:1500px){
 .hero-card{min-height:590px}
 .hero-grid{max-width:1750px}
 .facility-grid{grid-template-columns:repeat(3,minmax(0,1fr))}
 .facility-image{height:290px}
 .section{padding-top:68px;padding-bottom:68px}
}
@media(max-width:1200px){
 .layout{grid-template-columns:175px minmax(0,1fr)}
 .hero-card{min-height:500px}.hero h1{font-size:clamp(42px,4vw,60px)}
 .hero p{font-size:15px}.facility-image{height:230px}
 .availability-item{grid-template-columns:65px minmax(0,1fr) 70px;padding:15px}
 .availability-thumb{width:65px;height:65px}
}
@media(max-width:850px){
 .topbar{height:68px}.layout{grid-template-columns:1fr;min-height:calc(100vh - 68px)}
 .sidebar{top:68px;height:auto;padding:8px 10px}
 .section{padding:34px 20px}
 .hero-section{min-height:auto;padding-top:22px;padding-bottom:30px}
 .hero-card{min-height:520px}.hero h1{font-size:clamp(42px,7vw,62px)}
 .hero p{font-size:15px}.stats-panel{padding:22px}
 .section-heading h2{font-size:clamp(30px,5vw,42px)}
 .facility-grid{grid-template-columns:repeat(2,minmax(0,1fr))}
 .facility-image{height:220px}
 .feature-grid{grid-template-columns:repeat(2,minmax(0,1fr))}
 .closing-banner{margin:0 20px 30px}
}
@media(max-width:560px){
 body{font-size:15px}.topbar{height:62px;padding:0 12px}.brand{font-size:19px}
 .section{padding:30px 14px}.hero-card{min-height:560px;padding:24px;align-items:flex-start}
 .hero-copy{width:100%}.hero h1{font-size:44px}.hero p{font-size:14px;max-width:100%}
 .hero-art{width:90%;height:245px;right:0;bottom:0}
 .hero-tags{font-size:11px;gap:9px;max-width:90%}
 .stats-grid{gap:9px}.stat-card{padding:13px;min-height:112px}.stat-card strong{font-size:28px}
 .section-heading{align-items:flex-start;flex-direction:column}.section-heading h2{font-size:32px}
 .filter-btn{font-size:12px;padding:9px 13px}
 .facility-grid,.feature-grid,.steps{grid-template-columns:1fr}
 .facility-image{height:245px}.facility-info h3{font-size:20px}
 .availability-item{grid-template-columns:55px minmax(0,1fr) 52px;gap:10px;padding:12px}
 .availability-thumb{width:55px;height:55px}.availability-name{font-size:13px}
 .availability-sub{font-size:11px}.capacity{font-size:13px}
 .insight-card{min-height:390px;padding:23px}.insight-card h3{font-size:29px}
 .feature-card{min-height:185px;padding:23px}.feature-card h3{font-size:20px}
 .visit-action{padding:15px}.visit-action .action-icon{width:44px;height:44px}
 .closing-banner{min-height:280px;margin:0 14px 24px;padding:24px}
 .closing-banner h2{font-size:32px}.closing-banner p{font-size:13px}
}


/* Activity recommendation feature */
.recommend-section{background:linear-gradient(180deg,#f3f0ff,#fff 75%)}
.recommend-panel{background:#fff;border:1px solid #e8e3ff;border-radius:22px;padding:clamp(18px,3vw,30px);box-shadow:var(--shadow)}
.recommend-form{display:flex;gap:12px;flex-wrap:wrap;margin:22px 0;align-items:center}
.recommend-form select{flex:1;min-width:220px;height:48px;padding:0 14px;border:1px solid #ded9f8;border-radius:12px;background:white;color:var(--ink)}
.recommend-results{display:grid;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));gap:14px;margin-top:18px}
.recommend-card{border:1px solid var(--line);border-radius:17px;padding:18px;display:flex;flex-direction:column;gap:10px;background:#fff}
.recommend-card.best{border-color:#b6aaff;box-shadow:0 10px 28px #5338e912}
.recommend-rank{font-size:11px;font-weight:900;letter-spacing:.08em;text-transform:uppercase;color:var(--purple)}
.recommend-card h3{font-size:19px}.recommend-reason{font-size:13px;color:var(--muted);line-height:1.6;min-height:40px}
.recommend-meter{height:7px;border-radius:99px;background:#efedfa;overflow:hidden}.recommend-meter span{display:block;height:100%;border-radius:99px;background:linear-gradient(90deg,#a89aff,var(--purple))}
.recommend-actions{display:flex;align-items:center;justify-content:space-between;gap:10px;margin-top:4px}.recommend-actions small{font-size:11px;color:var(--muted)}
.recommend-note{font-size:12px;color:var(--muted);margin-top:15px}


/* LiveAmenity dusk-glass theme: visual-only overrides; existing JSP forms and actions stay intact. */
:root{--purple:#78f0d4;--purple2:#42cbb3;--ink:#f6f8f7;--muted:#c1c7c6;--line:rgba(232,244,240,.18);--paper:rgba(24,29,31,.78);--page:#151a1c;--mint:#a0f7e4;--green:#78f0d4;--shadow:0 16px 44px rgba(0,0,0,.25)}
html{background:#151a1c}
body{color:#f6f8f7;background:linear-gradient(rgba(10,14,16,.32),rgba(10,14,16,.48)),url('https://i.pinimg.com/1200x/a3/05/89/a3058923fe74f5101f3a73a426ddaf1f.jpg') center center/cover fixed no-repeat}
body:before{content:"";position:fixed;inset:0;z-index:-1;pointer-events:none;background:linear-gradient(180deg,rgba(11,15,18,.38),rgba(10,14,16,.64) 72%,rgba(10,14,16,.72))}
.recommend-alert{margin:4px 0 18px;padding:14px 16px;border:1px solid rgba(120,240,212,.32);border-radius:13px;background:rgba(120,240,212,.09);color:#e8fff8;line-height:1.65}
.recommend-status{display:inline-flex;align-items:center;gap:6px;margin-bottom:7px;padding:5px 9px;border-radius:20px;font-size:10px;font-weight:900;letter-spacing:.04em;text-transform:uppercase;background:rgba(120,240,212,.15);color:#8cf3dc}
.recommend-status.full{background:rgba(255,104,124,.14);color:#ff9daa}
.recommend-status.busy{background:rgba(255,196,92,.14);color:#ffd28a}
.recheck-form{display:inline-block}
.recheck-btn{border:1px solid rgba(120,240,212,.5);border-radius:10px;background:rgba(120,240,212,.12);color:#8cf3dc;padding:9px 12px;font-size:11px;font-weight:850}
.recheck-btn:hover{background:#78f0d4;color:#10221e}
.topbar{background:rgba(19,24,27,.78);border-bottom-color:rgba(238,250,246,.18);backdrop-filter:blur(22px)}
.brand-mark{background:linear-gradient(145deg,#66747a,#30383d);border:1px solid rgba(255,255,255,.24);box-shadow:0 8px 22px #0004}
.brand-name span{color:#78f0d4}
.topnav a{color:#d5dcda}.topnav a:hover,.topnav a.active{background:rgba(120,240,212,.17);color:#8ff5de}
.top-search{border-color:rgba(255,255,255,.2);background:rgba(255,255,255,.08)}.top-search svg{color:#c4ceca}.top-search input{color:#fff}.top-search input::placeholder{color:#c0c7c4}
.profile{border-color:rgba(255,255,255,.2);background:rgba(255,255,255,.08);color:#f5f8f7}.avatar{background:#78f0d4;color:#10211e}
.layout{background:transparent}
.sidebar{background:rgba(18,23,26,.78);border-right-color:rgba(238,250,246,.16);backdrop-filter:blur(22px)}
.side-caption{color:#aab8b4}.side-links a{color:#d1d8d5}.side-links a .side-icon{color:#80f0d7}.side-links a:hover,.side-links a.active{background:rgba(120,240,212,.16);color:#8ff5de}
.sidebar-promo{background:rgba(255,255,255,.075);border:1px solid rgba(255,255,255,.17);backdrop-filter:blur(16px)}.sidebar-promo p,.side-account small{color:#bac5c1}.side-account{border-top-color:rgba(255,255,255,.15)}
.hero-section{min-height:calc(100vh - 72px);background:linear-gradient(90deg,rgba(12,17,19,.28),rgba(12,17,19,.15)),url('https://i.pinimg.com/1200x/a3/05/89/a3058923fe74f5101f3a73a426ddaf1f.jpg') center 44%/cover fixed no-repeat;padding-top:30px;padding-bottom:30px}
.hero-card{background:rgba(23,29,31,.66);border:1px solid rgba(255,255,255,.27);backdrop-filter:blur(18px);box-shadow:0 22px 60px rgba(0,0,0,.28)}.hero-card:before{border-color:rgba(255,255,255,.12)}.hero-art{display:none}
.eyebrow{color:#7cf0d6}.eyebrow:before{background:#78f0d4}
.hero h1{color:#fff}.hero h1 span{color:#8bf4dc}.hero p{color:#e0e6e3}
.btn-primary{color:#09231e;background:linear-gradient(110deg,#8cf3dc,#61dfc5);box-shadow:0 8px 18px rgba(0,0,0,.2)}.btn-light{background:rgba(16,22,24,.48);color:#fff;border:1px solid rgba(141,244,220,.5)}
.hero-tags{color:#e1e8e5}.hero-tags b{color:#81f1d9}
.stats-panel{background:rgba(22,28,30,.74);border:1px solid rgba(255,255,255,.2);backdrop-filter:blur(20px);box-shadow:0 20px 55px rgba(0,0,0,.25)}.panel-kicker{color:#fff}.live-dot{color:#8af3dc;background:rgba(120,240,212,.16)}
.stat-card{border-color:rgba(255,255,255,.12);background:linear-gradient(145deg,rgba(255,255,255,.09),rgba(255,255,255,.045))}.stat-icon{background:rgba(120,240,212,.16);color:#81f2d9}.stat-card strong{color:#fff}.stat-card span{color:#c4ceca}
.occupancy-overview{background:rgba(255,255,255,.075);border:1px solid rgba(255,255,255,.1)}.occupancy-overview div:first-child{color:#f1f5f3}.track{background:rgba(255,255,255,.2)}.track span{background:linear-gradient(90deg,#67e5c8,#a0f7e4)}
.facilities-section,.availability-section,.how-section,.visits-section{background:rgba(13,18,20,.65);backdrop-filter:blur(8px)}
.section-heading h2{color:#fff}.section-heading p{color:#c4ceca}.section-heading .btn-light{background:rgba(255,255,255,.07);color:#fff;border-color:rgba(255,255,255,.22)}
.filter-btn{border-color:rgba(255,255,255,.2);background:rgba(255,255,255,.06);color:#d5ddda}.filter-btn.active,.filter-btn:hover{background:#78f0d4;border-color:#78f0d4;color:#10221e}
.facility-card{background:rgba(27,33,35,.88);border-color:rgba(255,255,255,.15);box-shadow:0 10px 28px rgba(0,0,0,.18)}.facility-card:hover{box-shadow:0 20px 38px rgba(0,0,0,.3)}.facility-label{color:#15312b;background:rgba(247,255,252,.95)}.facility-open{background:#78f0d4;color:#0d2822;box-shadow:0 7px 15px rgba(0,0,0,.24)}.facility-info h3{color:#fff}.facility-info p,.facility-bottom small{color:#c0c9c5}.facility-bottom{border-top-color:rgba(255,255,255,.12)}.facility-bottom small strong{color:#fff}.small-book{background:rgba(120,240,212,.14);border:1px solid rgba(120,240,212,.42);color:#8af4dc}.small-book:hover{background:#78f0d4;color:#10221e}.status.available{background:rgba(120,240,212,.16);color:#91f6df}.status.busy{background:rgba(255,192,91,.18);color:#ffd18b}.status.full{background:#ff9da5;color:#4b151b}
.availability-item{background:rgba(27,33,35,.86);border-color:rgba(255,255,255,.14);box-shadow:0 5px 17px rgba(0,0,0,.15)}.availability-name{color:#fff}.availability-sub,.capacity small{color:#bac5c1}.capacity{color:#fff}.availability-thumb{background:rgba(255,255,255,.08)}
.insight-card{background:linear-gradient(145deg,rgba(25,31,33,.88),rgba(37,43,44,.78));border:1px solid rgba(255,255,255,.18)}.insight-card h3{color:#fff}.insight-card p{color:#d0d8d4}.insight-number{color:#81f1d9}
.feature-card{background:rgba(27,33,35,.82);border-color:rgba(255,255,255,.14)}.feature-card:hover{background:rgba(41,52,52,.9)}.feature-card h3{color:#fff}.feature-card p{color:#c5ceca}.feature-number{background:rgba(120,240,212,.15);color:#80f1d8}
.step{background:rgba(27,33,35,.82);border-color:rgba(255,255,255,.14);color:#eaf0ed}.step b{background:#78f0d4;color:#10221e}.step span{color:#c2ccc8}
.recommend-section{background:rgba(13,18,20,.46);backdrop-filter:blur(3px)}.recommend-panel{background:rgba(24,30,32,.84);border-color:rgba(255,255,255,.16)}.recommend-panel p,.recommend-note{color:#c4ceca}.recommend-form select{border-color:rgba(255,255,255,.2);background:#222a2c;color:#fff}.recommend-card{background:rgba(255,255,255,.06);border-color:rgba(255,255,255,.14)}.recommend-card.best{border-color:rgba(120,240,212,.6);box-shadow:0 10px 28px rgba(0,0,0,.18)}.recommend-card h3{color:#fff}.recommend-reason,.recommend-actions small{color:#c4ceca}.recommend-rank{color:#81f1d9}.recommend-meter{background:rgba(255,255,255,.16)}.recommend-meter span{background:linear-gradient(90deg,#59d9bd,#9af5df)}
.visits-section{background:rgba(13,18,20,.72)}.visit-panel,.visit-action{background:rgba(27,33,35,.86);border-color:rgba(255,255,255,.15)}.panel-head{border-bottom-color:rgba(255,255,255,.12)}.panel-head h3,.visit-action h4,.visit-empty h4{color:#fff}.panel-head p,.visit-action p,.visit-empty p{color:#c4ceca}.visit-empty{color:#fff}.empty-icon,.visit-action .action-icon{background:rgba(120,240,212,.15);color:#80f1d8}
.closing-banner{background:linear-gradient(105deg,rgba(15,24,24,.94),rgba(27,43,42,.88));border:1px solid rgba(120,240,212,.28);box-shadow:var(--shadow)}.closing-banner h2{color:#fff}.closing-banner p{color:#d5e0db}.closing-banner .eyebrow{color:#83f2da!important}.closing-banner .btn{background:#78f0d4;color:#10221e}.closing-art{opacity:.24;mix-blend-mode:screen}
.footer{color:#c0c9c5;border-top-color:rgba(255,255,255,.14);background:rgba(16,21,23,.82)}
.secondary{border-color:rgba(255,255,255,.18);background:rgba(255,255,255,.08);color:#f5f8f7}.modal-bg{background:rgba(4,8,9,.72)}.modal{background:#202729;border:1px solid rgba(255,255,255,.17);color:#f5f8f7}.modal-head{border-bottom-color:rgba(255,255,255,.13)}.modal-head h2{color:#fff}.close{border-color:rgba(255,255,255,.18);background:rgba(255,255,255,.08);color:#fff}.modal-body p{color:#c4ceca}.selected-facility{background:rgba(255,255,255,.07)}.selected-facility strong{color:#fff}.selected-facility small{color:#c4ceca}.form-input{background:rgba(255,255,255,.07);border-color:rgba(255,255,255,.2);color:#fff}.form-input::placeholder{color:#aab6b1}.toast{background:#78f0d4;color:#10221e}
@media(max-width:850px){.hero-section{background-attachment:scroll}.hero-card{background:rgba(23,29,31,.78)}.stats-panel{background:rgba(22,28,30,.86)}}


.my-bookings-panel{padding:24px;border-top:1px solid rgba(175,224,200,.18)}
.my-bookings-panel h3{margin:0 0 18px;color:#fff;font-size:17px}
.booking-detail-row{padding:15px;margin-bottom:12px;border:1px solid rgba(175,224,200,.16);border-radius:12px;background:rgba(255,255,255,.04);color:#e8f4ee;line-height:1.8;overflow-wrap:anywhere;font-size:12px}
.bookings-empty{color:#b8c9c0;line-height:1.7;font-size:12px;margin-bottom:18px}
.my-bookings-panel[hidden]{display:none}
.hide-bookings-btn{margin-top:4px}

/* Search and resident profile dropdown fixes */
.profile-wrap{position:relative;flex-shrink:0}
.profile{display:flex;align-items:center;gap:9px;border:1px solid var(--line);background:rgba(24,29,31,.88);color:var(--ink);padding:6px 12px 6px 6px;border-radius:26px;font-size:12px;font-weight:750;white-space:nowrap;cursor:pointer}
.profile:hover,.profile:focus-visible{border-color:var(--mint);outline:none;box-shadow:0 0 0 3px rgba(120,240,212,.12)}
.profile-chevron{font-size:13px;color:var(--mint);transition:transform .2s}
.profile[aria-expanded="true"] .profile-chevron{transform:rotate(180deg)}
.profile-menu{position:absolute;right:0;top:calc(100% + 12px);width:255px;padding:9px;background:#202729;border:1px solid rgba(232,244,240,.2);border-radius:16px;box-shadow:0 18px 45px rgba(0,0,0,.4);z-index:500;color:#f6f8f7}
.profile-menu[hidden]{display:none}
.profile-menu-heading{display:flex;align-items:center;gap:10px;padding:12px;border-bottom:1px solid rgba(232,244,240,.14);margin-bottom:6px;overflow:hidden}
.profile-menu-heading strong{display:block;font-size:13px;max-width:175px;overflow-wrap:anywhere}
.profile-menu-heading small{display:block;font-size:11px;color:#b9c7c2;margin-top:2px}
.profile-menu>a{display:block;padding:11px 12px;border-radius:10px;font-size:12px;color:#e9f4f0}
.profile-menu>a:hover,.profile-menu>a:focus-visible{background:rgba(120,240,212,.12);color:#78f0d4;outline:none}
.profile-menu-note{border-top:1px solid rgba(232,244,240,.14);padding:10px 12px 5px;margin-top:5px;font-size:10px;color:#aebdb7;overflow-wrap:anywhere}
.top-search{flex-shrink:1;min-width:160px}
.top-search:focus-within{border-color:var(--mint);box-shadow:0 0 0 3px rgba(120,240,212,.1)}
@media(max-width:560px){.profile-name{display:none}.profile{gap:5px;padding-right:8px}.profile-menu{position:fixed;top:68px;right:12px;width:min(280px,calc(100vw - 24px))}.top-search{display:flex;min-width:0;width:38px;padding:0 10px;transition:width .2s}.top-search:focus-within{width:min(220px,48vw)}.top-search input{width:0;opacity:0}.top-search:focus-within input{width:100%;opacity:1}}

</style>
</head>
<body>
<header class="topbar">
 <a class="brand" href="#overview"><span class="brand-mark">L</span><span class="brand-name">Live<span>Amenity</span></span></a>
 <nav class="topnav"><a class="active" href="#overview">Overview</a><a href="#facilities">Facilities</a><a href="#recommend">Recommendations</a><a href="#availability">Availability</a><a href="#visits">My Visits</a></nav>
 <div class="top-right">
  <label class="top-search"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="10.5" cy="10.5" r="6.5"/><path d="m15.5 15.5 5 5"/></svg><input id="topSearch" placeholder="Search gym, badminton, study room..." aria-label="Search facilities"></label>
  <button type="button" class="secondary" style="padding:8px 10px" onclick="showToast('You are viewing the latest facility information.')">♧</button>
  <div class="profile-wrap">
   <button type="button" class="profile" id="profileToggle" aria-haspopup="true" aria-expanded="false" aria-controls="profileMenu">
    <span class="avatar"><%= displayName.substring(0,1).toUpperCase() %></span><span class="profile-name"><%= displayName %></span><span class="profile-chevron" aria-hidden="true">▾</span>
   </button>
   <div class="profile-menu" id="profileMenu" hidden>
    <div class="profile-menu-heading"><span class="avatar"><%= displayName.substring(0,1).toUpperCase() %></span><div><strong><%= displayName %></strong><small>Resident account</small></div></div>
    <a href="#visits" data-profile-close>My visits</a>
    <a href="#facilities" data-profile-close>Explore facilities</a>
    <a href="report">Download facility report</a>
    <div class="profile-menu-note">Signed in as <%= user.getEmail() == null ? "resident" : user.getEmail() %></div>
   </div>
  </div>
 </div>
</header>
<div class="layout">
<aside class="sidebar">
 <div class="side-caption">YOUR SPACE</div>
 <nav class="side-links">
  <a class="active" href="#overview"><span class="side-icon">⌂</span>Overview</a>
  <a href="#facilities"><span class="side-icon">▦</span>Explore Facilities</a>
   <a href="#recommend"><span class="side-icon">✦</span>Recommendations</a>
  <a href="#availability"><span class="side-icon">◷</span>Live Availability</a>
  <a href="#visits"><span class="side-icon">▣</span>My Visits</a>
  <a href="#reports"><span class="side-icon">▥</span>Reports</a>
 </nav>
 <div class="sidebar-bottom">
  <div class="sidebar-promo"><strong>Better spaces.<br>Better everyday living.</strong><p>Your shared community, all in one place.</p><img src="https://i.pinimg.com/1200x/a3/05/89/a3058923fe74f5101f3a73a426ddaf1f.jpg" alt="Modern apartment community illustration"></div>
  <div class="side-account"><span class="avatar"><%= displayName.substring(0,1).toUpperCase() %></span><div><%= displayName %><small>Resident account</small></div></div>
 </div>
</aside>
<main>
<section class="section hero-section" id="overview">
 <div class="hero-grid">
  <div class="hero-card">
   <div class="hero-copy">
    <div class="eyebrow">Shared spaces, brighter days</div>
    <h1>Welcome back,<br><span><%= displayName %>!</span></h1>
    <p>Discover, book and enjoy shared facilities in your community. Make everyday living easier, healthier and more connected.</p>
    <div class="btn-row"><a class="btn btn-primary" href="#facilities">Explore facilities <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M5 12h14m-6-6 6 6-6 6"/></svg></a><a class="btn btn-light" href="#visits">Manage my visit</a></div>
    <div class="hero-tags"><span><b>✦</b><%= total %> shared facilities</span><span><b>◷</b> Live occupancy</span><span><b>⌂</b> Your community</span></div>
   </div>
   <img class="hero-art" src="https://i.pinimg.com/1200x/a3/05/89/a3058923fe74f5101f3a73a426ddaf1f.jpg" alt="Modern residential apartment building">
  </div>
  <aside class="stats-panel">
   <div class="panel-kicker">Quick Stats <span class="live-dot">● Live system</span></div>
   <div class="stats-grid">
    <div class="stat-card"><div class="stat-icon">▦</div><strong><%= total %></strong><span>Total facilities</span></div>
    <div class="stat-card"><div class="stat-icon">✦</div><strong><%= available %></strong><span>Available now</span></div>
    <div class="stat-card"><div class="stat-icon">◷</div><strong><%= occupancyPct %>%</strong><span>Overall occupancy</span></div>
    <div class="stat-card"><div class="stat-icon">♙</div><strong><%= capacity - occupied %></strong><span>Open spaces</span></div>
   </div>
   <div class="occupancy-overview"><div><span>Community occupancy</span><strong><%= occupied %> / <%= capacity %></strong></div><div class="track"><span style="--fill:<%= occupancyPct %>%"></span></div></div>
  </aside>
 </div>
</section>


<section class="section recommend-section" id="recommend">
 <div class="section-heading"><div><div class="eyebrow">LiveAmenity intelligence</div><h2>Find a facility for what you want to do.</h2><p>Choose an activity to see suitable facilities ranked by activity match and current occupancy.</p></div></div>
 <div class="recommend-panel">
  <form class="recommend-form" action="${pageContext.request.contextPath}/dashboard#recommend" method="get">
   <select name="activity" aria-label="Choose an activity" required>
    <option value="">Choose an activity...</option>
    <option value="exercise" <%= "exercise".equals(selectedActivity) ? "selected" : "" %>>Exercise / fitness</option>
    <option value="badminton" <%= "badminton".equals(selectedActivity) ? "selected" : "" %>>Play badminton</option>
    <option value="swimming" <%= "swimming".equals(selectedActivity) ? "selected" : "" %>>Swimming</option>
    <option value="yoga" <%= "yoga".equals(selectedActivity) ? "selected" : "" %>>Yoga / wellness</option>
    <option value="study" <%= "study".equals(selectedActivity) ? "selected" : "" %>>Study / focus</option>
   </select>
   <button class="btn btn-primary" type="submit">Recommend facilities →</button>
  </form>
  <% if (!selectedActivity.isBlank()) { %>
   <div class="eyebrow">Recommended options</div>
   <% if (recommendationMessage != null && !recommendationMessage.isBlank()) { %>
    <div class="recommend-alert">
     <% if (preferredFacilityFull) { %><span class="recommend-status full">Preferred facility full</span>
     <% } else if (preferredFacilityBusy) { %><span class="recommend-status busy">High occupancy</span>
     <% } else { %><span class="recommend-status">Live recommendation</span><% } %>
     <div><%= recommendationMessage %></div>
    </div>
   <% } %>
   <% if (recommendedFacilities == null || recommendedFacilities.isEmpty()) { %>
    <p style="margin-top:14px;color:var(--muted)">No suitable facilities are available right now. Please recheck shortly or choose another activity.</p>
   <% } else { int rank = 0; RecommendationService recommendationService = new RecommendationService(); %>
    <div class="recommend-results">
     <% for (Facility rf : recommendedFacilities) {
          int rcap = rf.getCapacity(), rocc = rf.getOccupancy();
          int rfill = rcap <= 0 ? 100 : (int)Math.round(rocc * 100.0 / rcap);
          int scorePct = (int)Math.round(recommendationService.calculateScore(rf, selectedActivity) * 100.0);
          boolean isPreferred = preferredFacility != null && rf.getId() == preferredFacility.getId();
          boolean isFull = recommendationService.isFull(rf);
          boolean isBusy = recommendationService.isBusy(rf);
          String reason = recommendationService.getReason(rf, selectedActivity, preferredFacility);
     %>
      <article class="recommend-card <%= isPreferred ? "best" : "" %>">
       <span class="recommend-rank"><%= isPreferred ? "✦ Your chosen activity" : "Alternative " + rank %></span>
       <% if (isFull) { %><span class="recommend-status full">Full · Recheck later</span>
       <% } else if (isBusy) { %><span class="recommend-status busy">Busy · Quieter options below</span>
       <% } else { %><span class="recommend-status">Available now</span><% } %>
       <h3><%= rf.getName() %></h3>
       <p class="recommend-reason"><%= reason %></p>
       <div class="recommend-meter"><span style="width:<%= Math.max(0, Math.min(100, scorePct)) %>%"></span></div>
       <div class="recommend-actions"><small><%= rocc %> / <%= rcap %> occupied · <%= rfill %>% full</small>
        <% if (isFull) { %>
         <form class="recheck-form" action="${pageContext.request.contextPath}/dashboard#recommend" method="get">
          <input type="hidden" name="activity" value="<%= selectedActivity %>">
          <button class="recheck-btn" type="submit">Recheck ↻</button>
         </form>
        <% } else { %>
         <form action="${pageContext.request.contextPath}/book" method="post"><input type="hidden" name="facilityId" value="<%= rf.getId() %>"><button class="small-book" type="submit">Book →</button></form>
        <% } %>
       </div>
      </article>
     <% rank++; } %>
    </div>
   <% } %>
   <p class="recommend-note">Recommendations update from current facility data. The preferred activity is checked first; available alternatives are ranked using activity suitability (70%) and unoccupied capacity (30%). Waiting times are not estimated without enough historical data.</p>
  <% } else { %>
   <p class="recommend-note">Choose an activity to see whether your preferred facility is available and get alternatives based on activity fit and live occupancy.</p>
  <% } %>
 </div>
</section>

<section class="section facilities-section" id="facilities">
 <div class="section-heading"><div><div class="eyebrow">Your amenities</div><h2>Find your kind of space.</h2><p>From fitness to focus time, there's a place for what you want to do.</p></div><a class="btn btn-light" href="#availability">Check live availability ↗</a></div>
 <div class="filters"><button class="filter-btn active" data-filter="all">All facilities</button><button class="filter-btn" data-filter="gym">Fitness</button><button class="filter-btn" data-filter="court">Sports</button><button class="filter-btn" data-filter="study">Study</button><button class="filter-btn" data-filter="pool">Recreation</button><button class="filter-btn" data-filter="yoga">Wellness</button><button class="filter-btn" data-filter="common">Common areas</button></div>
 <div class="facility-grid" id="facilityGrid">
 <% if(facilities!=null && !facilities.isEmpty()){int ix=0;for(Facility f:facilities){
    int cap=f.getCapacity(),occ=f.getOccupancy(),fill=cap<=0?0:(int)Math.round(occ*100.0/cap);
    String nm=f.getName()==null?"Facility":f.getName(),typ=f.getType()==null?"Shared space":f.getType(),loc=f.getLocation()==null?"Community":f.getLocation();
    String lower=(nm+" "+typ).toLowerCase(),kind="other",category="Community",image="https://i.pinimg.com/1200x/a3/05/89/a3058923fe74f5101f3a73a426ddaf1f.jpg",tagline="More amenities, more comfort.";
    if(lower.contains("gym")||lower.contains("fitness")){kind="gym";category="Fitness";image="https://i.pinimg.com/736x/f7/d9/80/f7d980657f69d51d2e055310133320d7.jpg";tagline="Stay fit. Stay active.";}
    else if(lower.contains("badminton")||lower.contains("court")||lower.contains("sport")){kind="court";category="Sports";image="https://i.pinimg.com/736x/57/aa/19/57aa193de637df42df304a5fdd8c0269.jpg";tagline="Play. Compete. Enjoy.";}
    else if(lower.contains("study")||lower.contains("library")){kind="study";category="Focus zone";image="https://i.pinimg.com/736x/32/c0/f2/32c0f273809be06159d2745764dfae65.jpg";tagline="Focus on what matters.";}
    else if(lower.contains("pool")||lower.contains("swim")){kind="pool";category="Recreation";image="https://i.pinimg.com/736x/eb/79/ae/eb79ae330f4699268c51d7eb3dfd47f1.jpg";tagline="Relax. Rejuvenate.";}
    else if(lower.contains("yoga")){kind="yoga";category="Wellness";image="https://i.pinimg.com/1200x/f9/c8/8d/f9c88d539912bc5385d81a2ee3b63c19.jpg";tagline="Unwind. Be mindful.";}
    else if(lower.contains("common")||lower.contains("lounge")){kind="common";category="Common area";image="https://i.pinimg.com/1200x/a3/05/89/a3058923fe74f5101f3a73a426ddaf1f.jpg";tagline="Meet. Chill. Reconnect.";}
    String status=fill>=100?"Full":fill>=75?"Busy":"Available",sc=fill>=100?"full":fill>=75?"busy":"available";
 %>
 <article class="facility-card" data-kind="<%= kind %>" data-search="<%= (nm+" "+typ+" "+loc).toLowerCase().replace("\"","&quot;") %>" style="animation-delay:<%= ix++*70 %>ms">
  <div class="facility-image <%= kind %>"><img src="<%= image %>" alt="Photograph of <%= nm %>" loading="lazy"><span class="facility-label"><%= category %></span><button type="button" class="facility-open" aria-label="View <%= nm %>" onclick="showDetails(this)">↗</button>
   <span class="facility-data" hidden data-id="<%= f.getId() %>" data-name="<%= nm.replace("\"","&quot;") %>" data-type="<%= typ.replace("\"","&quot;") %>" data-location="<%= loc.replace("\"","&quot;") %>" data-occ="<%= occ %>" data-cap="<%= cap %>" data-status="<%= status %>" data-image="<%= image.replace("&", "&amp;") %>"></span>
  </div>
  <div class="facility-info"><div class="facility-title-row"><div><h3><%= nm %></h3><p><%= tagline %></p></div><span class="status <%= sc %>"><%= status %></span></div>
   <div class="facility-bottom"><small><strong><%= occ %> / <%= cap %></strong> spots occupied</small><button type="button" class="small-book" onclick="bookFromCard(this)">Book facility →</button></div>
  </div>
 </article>
 <% }}else{%><div style="grid-column:1/-1;padding:35px;text-align:center;background:#fff;border:1px dashed #dcd8f2;border-radius:18px">No facilities are available right now.</div><%}%>
 </div>
 <div id="noResults" hidden style="padding:25px;text-align:center;color:var(--muted)">No facilities match this filter.</div>
</section>

<section class="section availability-section" id="availability">
 <div class="section-heading"><div><div class="eyebrow">Live facility intelligence</div><h2>Availability, at a glance.</h2><p>Check how busy each shared space is before you head over.</p></div><span class="live-dot">● Occupancy data</span></div>
 <div class="availability-layout">
  <div class="availability-list">
  <% if(facilities!=null){for(Facility f:facilities){
    int cap=f.getCapacity(),occ=f.getOccupancy(),fill=cap<=0?0:(int)Math.round(occ*100.0/cap);
    String nm=f.getName()==null?"Facility":f.getName(),lower=nm.toLowerCase(),image="https://i.pinimg.com/1200x/a3/05/89/a3058923fe74f5101f3a73a426ddaf1f.jpg";
    if(lower.contains("gym"))image="https://i.pinimg.com/736x/f7/d9/80/f7d980657f69d51d2e055310133320d7.jpg";else if(lower.contains("badminton")||lower.contains("court"))image="https://i.pinimg.com/736x/57/aa/19/57aa193de637df42df304a5fdd8c0269.jpg";else if(lower.contains("study"))image="https://i.pinimg.com/736x/32/c0/f2/32c0f273809be06159d2745764dfae65.jpg";else if(lower.contains("pool")||lower.contains("swim"))image="https://i.pinimg.com/736x/eb/79/ae/eb79ae330f4699268c51d7eb3dfd47f1.jpg";else if(lower.contains("yoga"))image="https://i.pinimg.com/1200x/f9/c8/8d/f9c88d539912bc5385d81a2ee3b63c19.jpg";
    String status=fill>=100?"Full":fill>=75?"Busy":"Available",sc=fill>=100?"full":fill>=75?"busy":"available";
  %>
   <div class="availability-item"><div class="availability-thumb"><img src="<%= image %>" alt="" loading="lazy"></div><div><div class="availability-name"><%= nm %> <span class="status <%= sc %>" style="margin-left:5px"><%= status %></span></div><div class="availability-sub">Current facility occupancy</div><div class="track"><span style="--fill:<%= Math.min(100,fill) %>%"></span></div></div><div class="capacity"><%= occ %> / <%= cap %><small>people</small></div></div>
  <% }} %>
  </div>
  <aside class="insight-card"><div><div class="eyebrow">Community snapshot</div><h3>Make time for the things that matter.</h3><p>Choose a quieter time, discover a new amenity, and make more of your shared spaces.</p></div><div><div class="insight-number"><%= 100-occupancyPct %>%</div><p>of total facility capacity is currently unoccupied.</p></div><img src="https://i.pinimg.com/1200x/a3/05/89/a3058923fe74f5101f3a73a426ddaf1f.jpg" alt="Modern apartment building" loading="lazy"></aside>
 </div>
</section>

<section class="section how-section" id="how">
 <div class="section-heading"><div><div class="eyebrow">Why LiveAmenity</div><h2>More than just a booking page.</h2><p>A smarter way to use the spaces you share with your community.</p></div></div>
 <div class="feature-grid">
  <article class="feature-card"><div class="feature-number">◷</div><h3>Know before you go.</h3><p>View facility occupancy and availability before deciding where to spend your time.</p></article>
  <article class="feature-card"><div class="feature-number">✦</div><h3>Book without the hassle.</h3><p>Choose a facility and create your booking in a few simple steps.</p></article>
  <article class="feature-card"><div class="feature-number">⌂</div><h3>Your spaces, together.</h3><p>Discover fitness, recreation, study and community spaces from one place.</p></article>
 </div>
 <div class="steps"><div class="step"><b>1</b><div><strong>Choose a facility</strong><span>Browse spaces and check availability.</span></div></div><div class="step"><b>2</b><div><strong>Confirm your booking</strong><span>Select the space you want to use.</span></div></div><div class="step"><b>3</b><div><strong>Arrive and enjoy</strong><span>Manage your visit from your dashboard.</span></div></div></div>
</section>

<section class="section visits-section" id="visits">
 <div class="section-heading"><div><div class="eyebrow">Your activity</div><h2>Make every visit count.</h2><p>Manage your facility visits and keep useful reports close by.</p></div></div>
 <div class="visit-layout">
  <div class="visit-panel">
   <div class="panel-head"><div><h3>My Visits</h3><p>Check in to a booking or finish a visit.</p></div><span class="live-dot">Resident tools</span></div>
   <div class="visit-empty"><div class="empty-icon">▣</div><h4>Ready for your next visit?</h4><p>View your bookings, check their status, and find the IDs you need to manage your visits.</p><button class="btn btn-primary" type="button" onclick="toggleMyBookings()">View My Bookings ↓</button></div>
   <div id="myBookingsPanel" class="my-bookings-panel" hidden>
    <h3>Your Bookings</h3>
    <% List<String> visitBookings = (List<String>) request.getAttribute("myBookings"); %>
    <% if (visitBookings == null || visitBookings.isEmpty()) { %>
     <p class="bookings-empty">You don't have any bookings yet. Explore the facilities and make your first reservation.</p>
    <% } else { for (String booking : visitBookings) { %>
     <div class="booking-detail-row"><span><%= booking %></span></div>
    <% } } %>
    <button class="small-book hide-bookings-btn" type="button" onclick="toggleMyBookings()">Hide Bookings ↑</button>
   </div>
  </div>
  <div class="visit-actions">
   <div class="visit-action"><span class="action-icon">↗</span><div><h4>Check in</h4><p>Start your booked facility visit.</p></div><button class="small-book" onclick="openVisit('checkin')">Open →</button></div>
   <div class="visit-action"><span class="action-icon">✓</span><div><h4>Check out</h4><p>Finish your current facility visit.</p></div><button class="small-book" onclick="openVisit('checkout')">Open →</button></div>
   <div class="visit-action" id="reports"><span class="action-icon">⇩</span><div><h4>Facility report</h4><p>Export facility capacity and occupancy.</p></div><a class="small-book" href="report">CSV report ↓</a></div>
   <div class="visit-action"><span class="action-icon">＋</span><div><h4>Find your next space</h4><p>Return to the facility catalogue.</p></div><a class="small-book" href="#facilities">Explore →</a></div>
  </div>
 </div>
</section>
<div class="closing-banner"><div style="position:relative;z-index:2"><div class="eyebrow" style="color:#e4ddff">Your community, your comfort</div><h2>Better spaces.<br>Stronger connections.</h2><p>Shared facilities for a healthier, happier and more connected community.</p><a class="btn" href="#facilities">Explore your community →</a></div><img class="closing-art" src="https://i.pinimg.com/1200x/a3/05/89/a3058923fe74f5101f3a73a426ddaf1f.jpg" alt="" loading="lazy"></div>
<footer class="footer"><span>© 2026 LiveAmenity · Shared-Amenity Management Platform</span><span>Discover · Reserve · Enjoy</span></footer>
</main>
</div>

<div class="modal-bg" id="bookingModal" role="dialog" aria-modal="true" aria-labelledby="bookingTitle" onclick="outsideModal(event,'bookingModal')"><div class="modal"><div class="modal-head"><div><div class="eyebrow">Facility reservation</div><h2 id="bookingTitle">Book your space.</h2></div><button class="close" type="button" onclick="closeModal('bookingModal')" aria-label="Close">×</button></div><div class="modal-body"><div class="selected-facility"><img id="bookingImage" src="https://i.pinimg.com/736x/f7/d9/80/f7d980657f69d51d2e055310133320d7.jpg" alt=""><div><strong id="bookingName">Facility</strong><small id="bookingInfo">Facility details</small></div></div><p>Confirm the facility below to submit your booking request.</p><form id="bookingForm" action="book" method="post"><input type="hidden" id="bookingFacilityId" name="facilityId"><div class="modal-actions"><button class="secondary" type="button" onclick="closeModal('bookingModal')">Cancel</button><button class="btn btn-primary" type="submit">Confirm booking →</button></div></form></div></div></div>
<div class="modal-bg" id="detailsModal" role="dialog" aria-modal="true" aria-labelledby="detailsTitle" onclick="outsideModal(event,'detailsModal')"><div class="modal"><div class="modal-head"><div><div class="eyebrow">Facility details</div><h2 id="detailsTitle">Facility</h2></div><button class="close" type="button" onclick="closeModal('detailsModal')" aria-label="Close">×</button></div><div class="modal-body"><div class="selected-facility"><img id="detailImage" src="https://i.pinimg.com/736x/f7/d9/80/f7d980657f69d51d2e055310133320d7.jpg" alt=""><div><strong id="detailType">Facility type</strong><small id="detailLocation">Location</small></div></div><p id="detailOccupancy"></p><div class="modal-actions"><button class="secondary" type="button" onclick="closeModal('detailsModal')">Close</button><button class="btn btn-primary" type="button" onclick="bookFromDetails()">Book this facility →</button></div></div></div></div>
<div class="modal-bg" id="visitModal" role="dialog" aria-modal="true" aria-labelledby="visitTitle" onclick="outsideModal(event,'visitModal')"><div class="modal"><div class="modal-head"><div><div class="eyebrow">Visit management</div><h2 id="visitTitle">Check in</h2></div><button class="close" type="button" onclick="closeModal('visitModal')" aria-label="Close">×</button></div><div class="modal-body"><p>Enter the booking ID and facility ID associated with your visit.</p><form id="visitForm" method="post"><div class="form-row"><input class="form-input" name="bookingId" type="number" min="1" placeholder="Booking ID" required><input class="form-input" name="facilityId" type="number" min="1" placeholder="Facility ID" required></div><div class="modal-actions"><button class="secondary" type="button" onclick="closeModal('visitModal')">Cancel</button><button class="btn btn-primary" id="visitSubmit" type="submit">Check in →</button></div></form></div></div></div>
<div class="toast" id="toast" role="status" aria-live="polite"></div>
<script>
const $=id=>document.getElementById(id);let selectedFacility=null,toastTimer;
function openModal(id){$(id).classList.add("open");document.body.style.overflow="hidden"}
function closeModal(id){$(id).classList.remove("open");if(!document.querySelector(".modal-bg.open"))document.body.style.overflow=""}
function outsideModal(e,id){if(e.target.id===id)closeModal(id)}
function showToast(msg){const t=$("toast");t.textContent=msg;t.classList.add("show");clearTimeout(toastTimer);toastTimer=setTimeout(()=>t.classList.remove("show"),2600)}
function dataFor(card){const d=card.querySelector(".facility-data").dataset;return {id:d.id,name:d.name,type:d.type,location:d.location,occ:d.occ,cap:d.cap,status:d.status,image:d.image}}
function showDetails(button){const card=button.closest(".facility-card"),d=dataFor(card);selectedFacility=d;$("detailsTitle").textContent=d.name;$("detailType").textContent=d.type||"Shared facility";$("detailLocation").textContent=d.location||"Community";$("detailImage").src=d.image;$("detailOccupancy").textContent="Current occupancy: "+d.occ+" of "+d.cap+". Status: "+d.status+".";openModal("detailsModal")}
function bookFromCard(button){openBooking(dataFor(button.closest(".facility-card")))}
function openBooking(d){selectedFacility=d;closeModal("detailsModal");$("bookingFacilityId").value=d.id;$("bookingName").textContent=d.name;$("bookingInfo").textContent=d.location+" · "+d.occ+" / "+d.cap+" currently occupied";$("bookingImage").src=d.image;openModal("bookingModal")}
function bookFromDetails(){if(selectedFacility)openBooking(selectedFacility)}
function openVisit(mode){const checkout=mode==="checkout";$("visitForm").action=checkout?"checkout":"checkin";$("visitTitle").textContent=checkout?"Check out of your visit":"Check in to your visit";$("visitSubmit").textContent=checkout?"Confirm check out →":"Confirm check in →";openModal("visitModal")}

function toggleMyBookings(){const panel=$("myBookingsPanel");const willOpen=panel.hidden;panel.hidden=!willOpen;if(willOpen){panel.scrollIntoView({behavior:"smooth",block:"nearest"})}}
let activeFacilityFilter="all";
function applyFacilityFilters(){
 const q=$("topSearch").value.trim().toLowerCase();
 let visible=0;
 document.querySelectorAll(".facility-card").forEach(card=>{
  const searchText=(card.dataset.search||"").toLowerCase();
  const matchesSearch=!q||searchText.includes(q);
  const matchesFilter=activeFacilityFilter==="all"||card.dataset.kind===activeFacilityFilter;
  const show=matchesSearch&&matchesFilter;
  card.hidden=!show;
  if(show)visible++;
 });
 $("noResults").hidden=visible>0;
}
$("topSearch").addEventListener("input",applyFacilityFilters);
$("topSearch").addEventListener("keydown",e=>{if(e.key==="Enter"){e.preventDefault();$("facilities").scrollIntoView({behavior:"smooth"});}});
document.querySelectorAll(".filter-btn").forEach(btn=>btn.addEventListener("click",()=>{
 document.querySelectorAll(".filter-btn").forEach(b=>b.classList.remove("active"));
 btn.classList.add("active");activeFacilityFilter=btn.dataset.filter||"all";applyFacilityFilters();
}));
const profileToggle=$("profileToggle"),profileMenu=$("profileMenu");
function setProfileMenu(open){profileMenu.hidden=!open;profileToggle.setAttribute("aria-expanded",String(open));}
profileToggle.addEventListener("click",e=>{e.stopPropagation();setProfileMenu(profileMenu.hidden);});
profileMenu.addEventListener("click",e=>{if(e.target.closest("a"))setProfileMenu(false);});
document.addEventListener("click",e=>{if(!e.target.closest(".profile-wrap"))setProfileMenu(false);});
document.addEventListener("keydown",e=>{if(e.key==="Escape"){setProfileMenu(false);document.querySelectorAll(".modal-bg.open").forEach(m=>closeModal(m.id));profileToggle.focus();}});
document.querySelectorAll(".side-links a,.topnav a").forEach(a=>a.addEventListener("click",function(){document.querySelectorAll(".side-links a,.topnav a").forEach(x=>x.classList.remove("active"));document.querySelectorAll('a[href="'+this.getAttribute("href")+'"]').forEach(x=>x.classList.add("active"))}));
$("bookingForm").addEventListener("submit",function(){const b=this.querySelector('button[type="submit"]');b.textContent="Submitting booking...";b.disabled=true});
$("visitForm").addEventListener("submit",function(){$("visitSubmit").textContent="Processing...";$("visitSubmit").disabled=true});
</script>
</body>
</html>
