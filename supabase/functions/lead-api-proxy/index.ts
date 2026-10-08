import { createClient } from "npm:@supabase/supabase-js@2";

const cors={"Access-Control-Allow-Origin":"*","Access-Control-Allow-Headers":"authorization, x-client-info, apikey, content-type","Access-Control-Allow-Methods":"POST, OPTIONS"};

Deno.serve(async (req:Request)=>{
  if(req.method==="OPTIONS") return new Response("ok",{headers:cors});
  try{
    const auth=req.headers.get("Authorization");
    if(!auth?.startsWith("Bearer ")) return new Response(JSON.stringify({error:"Missing authorization"}),{status:401,headers:{...cors,"Content-Type":"application/json"}});
    const url=Deno.env.get("SUPABASE_URL")!;
    const anon=Deno.env.get("SUPABASE_ANON_KEY")!;
    const service=Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const userClient=createClient(url,anon,{global:{headers:{Authorization:auth}}});
    const {data:{user},error:userError}=await userClient.auth.getUser();
    if(userError||!user) return new Response(JSON.stringify({error:"Unauthorized"}),{status:401,headers:{...cors,"Content-Type":"application/json"}});
    const {config_id}=await req.json();
    if(!config_id) return new Response(JSON.stringify({error:"config_id is required"}),{status:400,headers:{...cors,"Content-Type":"application/json"}});
    const admin=createClient(url,service);
    const {data:config,error}=await admin.from("api_configs").select("id,user_id,endpoint_url,auth_header_name").eq("id",config_id).eq("user_id",user.id).maybeSingle();
    if(error||!config) return new Response(JSON.stringify({error:"API configuration not found"}),{status:404,headers:{...cors,"Content-Type":"application/json"}});
    const endpoint=new URL(config.endpoint_url);
    if(endpoint.protocol!=="https:") return new Response(JSON.stringify({error:"Only HTTPS endpoints are allowed"}),{status:400,headers:{...cors,"Content-Type":"application/json"}});
    const headers:Record<string,string>={"Accept":"application/json"};
    const token=Deno.env.get("LEADS_API_TOKEN");
    if(token&&config.auth_header_name) headers[config.auth_header_name]=token;
    const upstream=await fetch(endpoint.toString(),{headers});
    const body=await upstream.text();
    return new Response(body,{status:upstream.status,headers:{...cors,"Content-Type":upstream.headers.get("content-type")||"application/json"}});
  }catch(e){
    return new Response(JSON.stringify({error:e instanceof Error?e.message:"Unexpected error"}),{status:500,headers:{...cors,"Content-Type":"application/json"}});
  }
});