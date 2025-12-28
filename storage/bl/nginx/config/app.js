function handler(r) {
    const PASSWORD = "af42asse";
    
    // Always check secret first
    if (r.args.secret === PASSWORD) {
        r.headersOut['Set-Cookie'] = `app_access=${PASSWORD}; Path=/; Max-Age=31536000; HttpOnly`;
        r.internalRedirect('@app');
        return;
    }
    
    // Then check cookie
    const cookies = r.headersIn['Cookie'] || '';
    if (cookies.includes(`app_access=${PASSWORD}`)) {
        r.internalRedirect('@app');
        return;
    }
    
    // No access - maintenance
    r.internalRedirect('@maintenance');
}

export default { handler };