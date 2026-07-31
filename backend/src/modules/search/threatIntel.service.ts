import axios from "axios";

const OTX_URL = "https://otx.alienvault.com/api/v1";

export async function searchThreatIntel(query: string) {
  try {
    console.log("=================================");
    console.log("searchThreatIntel called");
    console.log("Query:", query);

    let endpoint = "";

    // URL
    if (query.startsWith("http://") || query.startsWith("https://")) {
      endpoint = `${OTX_URL}/indicators/url/${encodeURIComponent(query)}/general`;
    }
    // IPv4
    else if (/^\d+\.\d+\.\d+\.\d+$/.test(query)) {
      endpoint = `${OTX_URL}/indicators/IPv4/${query}/general`;
    }
    // Domain
    else if (/^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/.test(query)) {
      endpoint = `${OTX_URL}/indicators/domain/${query}/general`;
    } else {
      console.log("Unsupported query type");
      return null;
    }

    console.log("Endpoint:", endpoint);
    console.log("API Key Loaded:", !!process.env.OTX_API_KEY);

    const { data } = await axios.get(endpoint, {
      headers: {
        "X-OTX-API-KEY": process.env.OTX_API_KEY!,
      },
    });

    console.log("✅ OTX API Success");
    console.log("Response:");
    console.dir(data, { depth: null });

    return data;
  } catch (err: any) {
    console.log("❌ OTX API Failed");

    if (err.response) {
      console.log("Status:", err.response.status);
      console.log("Response:", err.response.data);
    } else {
      console.log("Message:", err.message);
    }

    return null;
  }
}