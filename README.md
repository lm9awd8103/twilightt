<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Twilight Hub</title>

    <meta name="description" content="Twilight Hub - Roblox Script Hub">
    <meta name="theme-color" content="#8b5cf6">

    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        html {
            scroll-behavior: smooth;
        }

        body {
            font-family: Arial, Helvetica, sans-serif;
            background:
                radial-gradient(circle at 50% -10%, rgba(139, 92, 246, 0.25), transparent 35%),
                #07050c;
            color: #fff;
            min-height: 100vh;
            overflow-x: hidden;
        }

        /* Background glow */

        body::before {
            content: "";
            position: fixed;
            width: 500px;
            height: 500px;
            background: rgba(124, 58, 237, 0.10);
            filter: blur(120px);
            border-radius: 50%;
            top: 20%;
            left: 50%;
            transform: translateX(-50%);
            pointer-events: none;
            z-index: -1;
        }

        /* Navbar */

        nav {
            position: sticky;
            top: 0;
            z-index: 100;
            width: 100%;
            padding: 18px 7%;
            display: flex;
            align-items: center;
            justify-content: space-between;
            background: rgba(7, 5, 12, 0.78);
            backdrop-filter: blur(18px);
            border-bottom: 1px solid rgba(168, 85, 247, 0.12);
        }

        .brand {
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 21px;
            font-weight: 800;
            color: white;
            text-decoration: none;
        }

        .brand-icon {
            width: 35px;
            height: 35px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: linear-gradient(135deg, #a855f7, #6d28d9);
            box-shadow: 0 0 25px rgba(139, 92, 246, 0.35);
        }

        .brand span {
            color: #a855f7;
        }

        .nav-links {
            display: flex;
            gap: 28px;
            list-style: none;
        }

        .nav-links a {
            color: #aaa;
            text-decoration: none;
            font-size: 14px;
            transition: 0.2s;
        }

        .nav-links a:hover {
            color: #c084fc;
        }

        .discord-btn {
            padding: 10px 17px;
            border-radius: 10px;
            text-decoration: none;
            color: white;
            font-size: 13px;
            font-weight: 700;
            background: linear-gradient(135deg, #8b5cf6, #6d28d9);
            box-shadow: 0 5px 25px rgba(124, 58, 237, 0.25);
            transition: 0.2s;
        }

        .discord-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 30px rgba(124, 58, 237, 0.4);
        }

        /* Hero */

        .hero {
            min-height: 78vh;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            text-align: center;
            padding: 80px 20px;
        }

        .hero-badge {
            display: inline-flex;
            align-items: center;
            gap: 7px;
            padding: 8px 14px;
            margin-bottom: 25px;
            border: 1px solid rgba(168, 85, 247, 0.3);
            border-radius: 100px;
            background: rgba(139, 92, 246, 0.08);
            color: #c084fc;
            font-size: 12px;
            font-weight: 700;
        }

        .hero h1 {
            font-size: clamp(50px, 10vw, 95px);
            line-height: 0.95;
            letter-spacing: -4px;
            font-weight: 900;
            margin-bottom: 25px;
            background: linear-gradient(
                135deg,
                #ffffff 20%,
                #c084fc 55%,
                #7c3aed
            );
            -webkit-background-clip: text;
            background-clip: text;
            color: transparent;
        }

        .hero p {
            max-width: 650px;
            color: #999;
            line-height: 1.7;
            font-size: 16px;
            margin-bottom: 32px;
        }

        .hero-buttons {
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
            justify-content: center;
        }

        .primary-btn,
        .secondary-btn {
            border: none;
            padding: 14px 22px;
            border-radius: 11px;
            text-decoration: none;
            font-weight: 700;
            font-size: 14px;
            cursor: pointer;
            transition: 0.2s;
        }

        .primary-btn {
            color: white;
            background: linear-gradient(135deg, #8b5cf6, #6d28d9);
            box-shadow: 0 8px 35px rgba(124, 58, 237, 0.25);
        }

        .secondary-btn {
            color: #ddd;
            background: #12101a;
            border: 1px solid #282131;
        }

        .primary-btn:hover,
        .secondary-btn:hover {
            transform: translateY(-2px);
        }

        /* Sections */

        section {
            width: 90%;
            max-width: 1150px;
            margin: auto;
            padding: 80px 0;
        }

        .section-title {
            text-align: center;
            margin-bottom: 40px;
        }

        .section-title h2 {
            font-size: 32px;
            margin-bottom: 10px;
        }

        .section-title p {
            color: #777;
            font-size: 14px;
        }

        /* Search */

        .search-box {
            max-width: 600px;
            margin: 0 auto 35px;
            position: relative;
        }

        .search-box input {
            width: 100%;
            padding: 16px 20px;
            border-radius: 13px;
            border: 1px solid #282131;
            outline: none;
            background: #100d17;
            color: white;
            font-size: 14px;
            transition: 0.2s;
        }

        .search-box input:focus {
            border-color: #8b5cf6;
            box-shadow: 0 0 20px rgba(139, 92, 246, 0.1);
        }

        /* Script grid */

        .script-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 18px;
        }

        .script-card {
            position: relative;
            padding: 24px;
            background:
                linear-gradient(
                    145deg,
                    rgba(139, 92, 246, 0.08),
                    rgba(12, 10, 18, 0.95)
                );
            border: 1px solid #251d31;
            border-radius: 17px;
            overflow: hidden;
            transition: 0.25s;
        }

        .script-card:hover {
            transform: translateY(-5px);
            border-color: rgba(168, 85, 247, 0.5);
            box-shadow: 0 15px 45px rgba(0, 0, 0, 0.3);
        }

        .script-icon {
            width: 45px;
            height: 45px;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 12px;
            background: rgba(139, 92, 246, 0.13);
            color: #c084fc;
            font-size: 20px;
            margin-bottom: 18px;
        }

        .script-card h3 {
            margin-bottom: 9px;
            font-size: 18px;
        }

        .script-card p {
            color: #777;
            font-size: 13px;
            line-height: 1.6;
            margin-bottom: 20px;
        }

        .tag {
            display: inline-block;
            padding: 5px 9px;
            margin-bottom: 15px;
            border-radius: 6px;
            background: rgba(139, 92, 246, 0.1);
            color: #b57cf5;
            font-size: 10px;
            font-weight: 700;
        }

        .script-buttons {
            display: flex;
            gap: 8px;
        }

        .copy-btn {
            flex: 1;
            padding: 11px;
            border: 0;
            border-radius: 9px;
            cursor: pointer;
            color: white;
            font-weight: 700;
            font-size: 12px;
            background: linear-gradient(135deg, #8b5cf6, #6d28d9);
            transition: 0.2s;
        }

        .copy-btn:hover {
            filter: brightness(1.15);
        }

        .view-btn {
            padding: 11px 14px;
            border-radius: 9px;
            border: 1px solid #30273b;
            color: #bbb;
            background: #110e17;
            cursor: pointer;
        }

        /* Loadstring */

        .load-section {
            padding-top: 30px;
        }

        .load-box {
            padding: 30px;
            border-radius: 18px;
            border: 1px solid #281f34;
            background: linear-gradient(
                145deg,
                rgba(124, 58, 237, 0.12),
                rgba(10, 8, 14, 0.9)
            );
        }

        .load-box h3 {
            margin-bottom: 10px;
        }

        .load-box p {
            color: #777;
            font-size: 13px;
            margin-bottom: 18px;
        }

        .code-container {
            display: flex;
            gap: 8px;
            background: #08070c;
            border: 1px solid #241c2e;
            padding: 7px;
            border-radius: 10px;
        }

        .code-container code {
            flex: 1;
            padding: 10px;
            color: #c084fc;
            font-family: monospace;
            font-size: 12px;
            overflow-x: auto;
            white-space: nowrap;
        }

        .code-copy {
            padding: 10px 15px;
            border: 0;
            border-radius: 8px;
            background: #8b5cf6;
            color: white;
            cursor: pointer;
            font-weight: 700;
        }

        /* About */

        .about-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 18px;
        }

        .about-card {
            text-align: center;
            padding: 30px 20px;
            border-radius: 15px;
            background: #0d0a12;
            border: 1px solid #211a29;
        }

        .about-card .number {
            font-size: 28px;
            font-weight: 900;
            color: #a855f7;
            margin-bottom: 8px;
        }

        .about-card p {
            color: #777;
            font-size: 13px;
        }

        /* Footer */

        footer {
            border-top: 1px solid #18131e;
            text-align: center;
            padding: 35px 20px;
            color: #555;
            font-size: 12px;
        }

        footer strong {
            color: #9b5de5;
        }

        /* Toast */

        .toast {
            position: fixed;
            left: 50%;
            bottom: 25px;
            transform: translate(-50%, 100px);
            background: #17121f;
            border: 1px solid #39284c;
            color: white;
            padding: 13px 20px;
            border-radius: 10px;
            font-size: 13px;
            z-index: 999;
            opacity: 0;
            transition: 0.3s;
            box-shadow: 0 10px 35px rgba(0,0,0,0.4);
        }

        .toast.show {
            transform: translate(-50%, 0);
            opacity: 1;
        }

        /* Mobile */

        @media (max-width: 800px) {

            nav {
                padding: 15px 5%;
            }

            .nav-links {
                display: none;
            }

            .hero {
                min-height: 70vh;
                padding: 70px 15px;
            }

            .hero h1 {
                letter-spacing: -2px;
            }

            .hero p {
                font-size: 14px;
            }

            section {
                width: 92%;
                padding: 60px 0;
            }

            .script-grid {
                grid-template-columns: 1fr;
            }

            .about-grid {
                grid-template-columns: 1fr;
            }

            .load-box {
                padding: 20px;
            }

            .code-container {
                flex-direction: column;
            }

            .code-copy {
                width: 100%;
            }
        }
    </style>
</head>

<body>

    <!-- NAVBAR -->

    <nav>
        <a href="#" class="brand">
            <div class="brand-icon">✦</div>
            Twilight<span>Hub</span>
        </a>

        <ul class="nav-links">
            <li><a href="#home">Home</a></li>
            <li><a href="#scripts">Scripts</a></li>
            <li><a href="#about">About</a></li>
        </ul>

        <!-- CHANGE THIS TO YOUR DISCORD INVITE -->
        <a class="discord-btn" href="https://discord.gg/" target="_blank">
            Discord
        </a>
    </nav>


    <!-- HERO -->

    <main id="home">

        <div class="hero">

            <div class="hero-badge">
                ✦ TWILIGHT HUB
            </div>

            <h1>
                TWILIGHT<br>
                HUB
            </h1>

            <p>
                Your central hub for Twilight scripts.
                Browse scripts, copy them instantly,
                and keep everything organized in one place.
            </p>

            <div class="hero-buttons">

                <a href="#scripts" class="primary-btn">
                    Browse Scripts
                </a>

                <a href="#loadstring" class="secondary-btn">
                    Get Loadstring
                </a>

            </div>

        </div>


        <!-- SCRIPTS -->

        <section id="scripts">

            <div class="section-title">
                <h2>Scripts</h2>
                <p>Browse the available Twilight Hub scripts.</p>
            </div>

            <div class="search-box">
                <input
                    type="text"
                    id="searchInput"
                    placeholder="Search scripts..."
                    onkeyup="searchScripts()"
                >
            </div>


            <div class="script-grid" id="scriptGrid">


                <!-- SCRIPT 1 -->

                <div class="script-card" data-name="twilight hub">

                    <div class="script-icon">
                        ✦
                    </div>

                    <span class="tag">
                        MAIN
                    </span>

                    <h3>
                        Twilight Hub
                    </h3>

                    <p>
                        The main Twilight Hub script.
                        Replace this description with your actual script information.
                    </p>

                    <div class="script-buttons">

                        <button
                            class="copy-btn"
                            onclick="copyScript('script1')"
                        >
                            Copy Script
                        </button>

                        <button
                            class="view-btn"
                            onclick="showScript('script1')"
                        >
                            View
                        </button>

                    </div>

                    <textarea id="script1" style="display:none;">
-- Twilight Hub
-- Put your Lua script here

print("Twilight Hub loaded!")
                    </textarea>

                </div>


                <!-- SCRIPT 2 -->

                <div class="script-card" data-name="example script">

                    <div class="script-icon">
                        ⚡
                    </div>

                    <span class="tag">
                        EXAMPLE
                    </span>

                    <h3>
                        Example Script
                    </h3>

                    <p>
                        Example script card. Replace this with
                        one of your actual scripts.
                    </p>

                    <div class="script-buttons">

                        <button
                            class="copy-btn"
                            onclick="copyScript('script2')"
                        >
                            Copy Script
                        </button>

                        <button
                            class="view-btn"
                            onclick="showScript('script2')"
                        >
                            View
                        </button>

                    </div>

                    <textarea id="script2" style="display:none;">
-- Example Twilight script

print("Example script loaded!")
                    </textarea>

                </div>


                <!-- ADD MORE SCRIPT CARDS HERE -->

            </div>

        </section>


        <!-- LOADSTRING -->

        <section id="loadstring" class="load-section">

            <div class="section-title">
                <h2>Loadstring</h2>
                <p>
                    Your executor can load your hosted script using its raw URL.
                </p>
            </div>

            <div class="load-box">

                <h3>
                    Twilight Hub
                </h3>

                <p>
                    Replace the URL below with the raw GitHub URL
                    of your actual Lua script.
                </p>

                <div class="code-container">

                    <code id="loadstringCode">
loadstring(game:HttpGet("YOUR_RAW_SCRIPT_URL"))()
                    </code>

                    <button
                        class="code-copy"
                        onclick="copyLoadstring()"
                    >
                        Copy
                    </button>

                </div>

            </div>

        </section>


        <!-- ABOUT -->

        <section id="about">

            <div class="section-title">
                <h2>Twilight Hub</h2>
                <p>Simple. Fast. Purple.</p>
            </div>

            <div class="about-grid">

                <div class="about-card">
                    <div class="number">✦</div>
                    <p>Twilight themed interface</p>
                </div>

                <div class="about-card">
                    <div class="number">⚡</div>
                    <p>Fast script access</p>
                </div>

                <div class="about-card">
                    <div class="number">∞</div>
                    <p>Add as many scripts as you want</p>
                </div>

            </div>

        </section>

    </main>


    <!-- FOOTER -->

    <footer>

        <p>
            © 2026 <strong>Twilight Hub</strong>.
            All rights reserved.
        </p>

    </footer>


    <!-- TOAST -->

    <div class="toast" id="toast">
        Copied!
    </div>


    <script>

        /* ---------------------------
           COPY SCRIPT
        --------------------------- */

        function copyScript(id) {

            const element = document.getElementById(id);

            const text = element.value;

            navigator.clipboard.writeText(text)
                .then(() => {

                    showToast("Script copied!");

                })
                .catch(() => {

                    showToast("Couldn't copy script.");

                });
        }


        /* ---------------------------
           COPY LOADSTRING
        --------------------------- */

        function copyLoadstring() {

            const text =
                document.getElementById("loadstringCode").innerText;

            navigator.clipboard.writeText(text)
                .then(() => {

                    showToast("Loadstring copied!")
