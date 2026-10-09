"use client";
import {FormEvent,useState} from "react";
import {supabase} from "../../lib/supabase";

export default function Login(){
 const [email,setEmail]=useState(""); const [password,setPassword]=useState(""); const [signup,setSignup]=useState(false); const [msg,setMsg]=useState(""); const [busy,setBusy]=useState(false);
 async function submit(e:FormEvent){e.preventDefault();setBusy(true);setMsg("");
  const r=signup?await supabase.auth.signUp({email,password}):await supabase.auth.signInWithPassword({email,password});
  if(r.error){setMsg(r.error.message);} else if(signup){setMsg("Check your email to confirm your account.");} else {window.location.href="/f_/"; return;}
  setBusy(false);
 }
 return <main className="min-h-screen grid place-items-center p-6"><div className="card w-full max-w-md p-7">
  <div className="text-2xl font-semibold">LeadFlow</div><p className="muted mt-1 mb-7">Private outreach command center</p>
  <form onSubmit={submit} className="space-y-4"><input className="field" type="email" placeholder="Email" value={email} onChange={e=>setEmail(e.target.value)} required/>
  <input className="field" type="password" placeholder="Password" value={password} onChange={e=>setPassword(e.target.value)} minLength={6} required/>
  <button className="btn btn-primary w-full" disabled={busy}>{busy?"Please wait…":signup?"Create account":"Sign in"}</button></form>
  {msg&&<p className="mt-4 text-sm text-slate-300">{msg}</p>}
  <button className="mt-5 text-sm text-blue-400" onClick={()=>setSignup(!signup)}>{signup?"Already have an account? Sign in":"Need an account? Create one"}</button>
 </div></main>
}