// convert hh:mm:ss → seconds
function parseDurationToSeconds(value: string): number {
  const regex = /^(\d+):([0-5]\d):([0-5]\d)$/;
  const match = value.match(regex);

  if (!match) {
    throw new Error("Sai định dạng hh:mm:ss");
  }

  const hours = parseInt(match[1], 10);
  const minutes = parseInt(match[2], 10);
  const seconds = parseInt(match[3], 10);

  return hours * 3600 + minutes * 60 + seconds;
}

// convert seconds → hh:mm:ss
function formatSecondsToDuration(totalSeconds: number): string {
  const hours = Math.floor(totalSeconds / 3600);
  const minutes = Math.floor((totalSeconds % 3600) / 60);
  const seconds = totalSeconds % 60;

  const pad = (n: number) => n.toString().padStart(2, "0");
  return `${pad(hours)}:${pad(minutes)}:${pad(seconds)}`;
}

type MyObj = {
  id: number;
  name: string;
  duration: number; // backend trả về (giây)
};

async function fetchData(): Promise<MyObj[]> {
  const res = await fetch("/api/endpoint");
  const data: MyObj[] = await res.json();

  // convert duration sang hh:mm:ss
  return data.map(obj => ({
    ...obj,
    duration: formatSecondsToDuration(obj.duration),
  }));
}


type MyObjView = {
  id: number;
  name: string;
  duration: string; // hh:mm:ss (frontend hiển thị)
};

async function sendData(obj: MyObjView) {
  const payload = {
    ...obj,
    duration: parseDurationToSeconds(obj.duration), // convert sang giây
  };

  await fetch("/api/endpoint", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload),
  });
}
