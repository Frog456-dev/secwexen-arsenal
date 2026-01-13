use std::net::TcpStream;
use std::thread;

fn scan(host: &str, port: u16) {
    if TcpStream::connect((host, port)).is_ok() {
        println!("[+] Port {} open", port);
    }
}

fn main() {
    let host = "127.0.0.1";
    println!("Scanning {}...", host);

    let mut threads = vec![];

    for port in 1..200 {
        let h = host.to_string();
        let t = thread::spawn(move || scan(&h, port));
        threads.push(t);
    }

    for t in threads {
        let _ = t.join();
    }
}
