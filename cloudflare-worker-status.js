// Cloudflare Worker: 状态页反代
// 拦截域名检测 API，返回正确格式的响应

const CHOREO_ORIGIN = 'https://your-choreo-app.choreoapis.dev';
const STATUS_SLUG = 'your-status-slug';

export default {
  async fetch(request) {
    const url = new URL(request.url);

    // 拦截域名检测 API - 返回正确格式
    if (url.pathname.startsWith('/api/v1/status-pages/domain/')) {
      const response = {
        message: "success",
        data: {
          id: "custom-domain",
          slug: STATUS_SLUG,
          title: "Status",
          description: "",
          icon: "",
          theme: "system",
          published: true,
          footer_text: "",
          auto_refresh_interval: 60,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        }
      };

      return new Response(JSON.stringify(response), {
        status: 200,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*'
        }
      });
    }

    // 其他请求代理到 Choreo
    const targetUrl = CHOREO_ORIGIN + url.pathname + url.search;

    const newRequest = new Request(targetUrl, {
      method: request.method,
      headers: request.headers,
      body: request.body,
      redirect: 'manual'
    });

    const response = await fetch(newRequest);

    return new Response(response.body, {
      status: response.status,
      statusText: response.statusText,
      headers: response.headers
    });
  }
}
