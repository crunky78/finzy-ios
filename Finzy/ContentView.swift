import SwiftUI

// MARK: - 1. 아이소메트릭 헬퍼
struct Iso {
    static let tileW: CGFloat = 100
    static let tileH: CGFloat = 50
    
    // 그리드(col, row) -> 화면 좌표(x, y)
    static func toWorld(col: CGFloat, row: CGFloat) -> CGPoint {
        CGPoint(x: (col - row) * (tileW / 2), y: (col + row) * (tileH / 2))
    }
    
    // 화면 좌표 차이(dx, dy) -> 그리드 변화량(dCol, dRow)
    static func toGridDelta(dx: CGFloat, dy: CGFloat) -> (dCol: CGFloat, dRow: CGFloat) {
        let dCol = (dx / (tileW / 2) + dy / (tileH / 2)) / 2
        let dRow = (dy / (tileH / 2) - dx / (tileW / 2)) / 2
        return (dCol, dRow)
    }
}

// MARK: - 2. 메인 뷰
struct ContentView: View {
    // 30x30 맵의 중앙에서 시작
    @State private var curCol: CGFloat = 15.0
    @State private var curRow: CGFloat = 15.0
    
    @State private var isWalking = false
    @State private var isFacingLeft = false
    @State private var currentFrame = 1
    @State private var selectedShop: Shop? = nil
    
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    var body: some View {
            GeometryReader { geo in
                let screenCenter = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
                let offset = Iso.toWorld(col: curCol, row: curRow)
                
                ZStack {
                    // 1. 배경
                    Color(red: 0.83, green: 0.93, blue: 0.81).ignoresSafeArea()
                    
                    // 2. 월드 레이어
                    ZStack {
                        tileLayer // 바닥 타일
                        
                        // ⭐️ 정렬 로직을 밖으로 빼지 말고, ZStack 안에서 직접 ForEach를 돌리세요.
                        // 건물들 배치
                        ForEach(sampleShops) { shop in
                            let pos = Iso.toWorld(col: shop.col, row: shop.row)
                            ShopNode(shop: shop)
                                .position(x: pos.x, y: pos.y)
                                .onTapGesture { selectedShop = shop }
                                .zIndex(shop.col + shop.row) // ⭐️ 아이소메트릭 깊이 정렬의 핵심!
                        }
                    }
                    .offset(x: -offset.x, y: -offset.y)
                    .position(screenCenter)
                    
                    // 3. 캐릭터 (중앙 고정)
                    AvatarView(isWalking: isWalking, isFacingLeft: isFacingLeft, frame: currentFrame)
                        .position(screenCenter)
                        // 캐릭터는 중앙에 있지만, zIndex를 줘서 건물 앞뒤로 가게 하고 싶다면
                        // 여기서는 중앙 고정 방식이므로 생략하거나 적절한 값을 줍니다.
                        .zIndex(curCol + curRow)

                    // 4. 터치 레이어
                    Color.black.opacity(0.0001)
                        .ignoresSafeArea()
                        .onTapGesture { location in
                            // 이미 이동 중이면 터치 무시 (스택 보호)
                            guard !isWalking else { return }
                            
                            let dx = location.x - screenCenter.x
                            let dy = location.y - screenCenter.y
                            let delta = Iso.toGridDelta(dx: dx, dy: dy)
                            
                            // 제한 없이 이동
                            moveCharacter(toCol: curCol + delta.dCol, toRow: curRow + delta.dRow)
                        }
                }
                .onReceive(timer) { _ in if isWalking { currentFrame = (currentFrame % 3) + 1 } }
            }
            .ignoresSafeArea()
        }
    
    func moveCharacter(toCol: CGFloat, toRow: CGFloat) {
        // ⭐️ 이미 걷고 있다면 새로운 입력을 무시해서 스택을 보호합니다.
        guard !isWalking else { return }
        
        let dist = sqrt(pow(toCol - curCol, 2) + pow(toRow - curRow, 2))
        if dist < 0.1 { return }
        
        isFacingLeft = toCol < curCol
        isWalking = true
        
        // 이동 거리에 따른 애니메이션 시간 (5.0은 속도 조절용 숫자)
        let duration = Double(dist / 5.0)
        
        withAnimation(.linear(duration: duration)) {
            curCol = toCol
            curRow = toRow
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            isWalking = false
        }
    }
    
    // 30x30 타일 레이어
    var tileLayer: some View {
        ZStack {
            ForEach(0..<30, id: \.self) { r in
                ForEach(0..<30, id: \.self) { c in
                    let pos = Iso.toWorld(col: CGFloat(c), row: CGFloat(r))
                    Diamond()
                        .fill(tileColor(c: c, r: r))
                        .frame(width: Iso.tileW, height: Iso.tileH)
                        .position(x: pos.x, y: pos.y)
                }
            }
        }
    }
    
    func tileColor(c: Int, r: Int) -> Color {
        // 도로 표시 (중앙 십자로)
        if c == 15 || r == 15 { return Color(red: 0.78, green: 0.72, blue: 0.58) }
        // 체스판 무늬로 타일 구분감 주기
        let v = Double((c + r) % 2) * 0.02
        return Color(red: 0.42 + v, green: 0.72 - v, blue: 0.33)
    }
}

// MARK: - 아바타 뷰
struct AvatarView: View {
    let isWalking: Bool; let isFacingLeft: Bool; let frame: Int
    var body: some View {
        VStack(spacing: 0) {
            // Assets에 이미지가 없다면 보이지 않을 수 있으므로 확인 필수!
            Image(isWalking ? "char_walk_\(isFacingLeft ? "left" : "right")\(frame)" : "char_\(isFacingLeft ? "left" : "right")")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
            
            Ellipse()
                .fill(Color.black.opacity(0.15))
                .frame(width: 50, height: 10)
                .blur(radius: 2)
        }
        .offset(y: -40) // 캐릭터 발바닥이 타일 중앙에 오도록 오프셋 조절
    }
}

// MARK: - 보조 모델 및 뷰
struct Shop: Identifiable {
    let id = UUID(); let name: String; let icon: String; let col: CGFloat; let row: CGFloat; let color1: Color; let color2: Color; let desc: String
}

let sampleShops: [Shop] = [
    Shop(name: "내 집", icon: "🏠", col: 15, row: 13, color1: .pink, color2: .orange, desc: "나의 아지트"),
    Shop(name: "시장", icon: "🛒", col: 18, row: 18, color1: .blue, color2: .cyan, desc: "상점"),
    Shop(name: "공원", icon: "🌳", col: 10, row: 10, color1: .green, color2: .mint, desc: "휴식처")
]

struct ShopNode: View {
    let shop: Shop
    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                RoundedRectangle(cornerRadius: 10).fill(LinearGradient(colors: [shop.color1, shop.color2], startPoint: .top, endPoint: .bottom)).frame(width: 50, height: 45)
                Text(shop.icon).font(.title2)
            }
            Text(shop.name).font(.system(size: 9)).padding(3).background(.black.opacity(0.4)).foregroundColor(.white).cornerRadius(5)
        }.offset(y: -25)
    }
}

struct ShopDetailView: View {
    let shop: Shop
    var body: some View {
        VStack(spacing: 20) {
            Capsule().fill(Color.gray.opacity(0.3)).frame(width: 40, height: 5).padding(.top)
            Text(shop.icon).font(.system(size: 60))
            Text(shop.name).font(.title).bold()
            Text(shop.desc).foregroundColor(.secondary)
            Spacer()
        }
    }
}

struct Diamond: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        p.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        p.closeSubpath()
        return p
    }
}
