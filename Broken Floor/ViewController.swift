//
//  ViewController.swift
//  Broken Floor
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // animation variables - duration, spring value
    var animTime = 0.5
    var animSpring: CGFloat = 0.6
    
    // colours used
    var primary = UIColor.rgb(44, 62, 80)
    var secondary = UIColor.rgb(46, 204, 113)
    var tertiary = UIColor.rgb(241, 196, 15)
    var quaternary = UIColor.rgb(252,87,94)
    
    // indication whether the game has started
    var started = false
    
    // keep track of touch
    var prevTouch = CGPoint()
    
    // storing of grid data
    var counter = [Int]()
    var storage = [Int]()
    
    // current player's position
    var currPos = [0,0] //x,y
    
    // grid
    var level: Int = 5
    
    // points of player
    var deducted = 0
    
    // view for swipe
    @IBOutlet weak var interactionView: UIView!
    
    // score labels
    @IBOutlet weak var scoreCounter: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    // highscore label
    @IBOutlet weak var highScore: UILabel!
    @IBOutlet weak var highScoreLabel: UILabel!
    
    // prompt label for player
    @IBOutlet weak var prompt: UILabel!
    
    // end game
    @IBOutlet weak var endButton: UIButton!
    
    // grid view
    @IBOutlet weak var collectionView: UICollectionView!
    // 1 grid width
    var width = CGFloat()
    
    // player circle
    var charater = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // randomise for values of grid data
        randomise()
        
        // set background colour
        view.backgroundColor = primary
        
        // collectionv view set up
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = primary
        
        // score label set up
        scoreCounter.textColor = secondary
        scoreCounter.text = "0"
        
        scoreLabel.textColor = secondary
        
        // highscore label set up
        highScore.textColor = secondary
        highScore.text = String(UserDefaults.standard.integer(forKey: "highscore"))
        
        highScoreLabel.textColor = secondary
        highScoreLabel.text = "HIGHSCORE"
        
        // prompt label set up
        prompt.textColor = secondary
        
        // end label set up
        endButton.setTitleColor(secondary, for: .normal)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // set value for width
        width = collectionView.frame.width/CGFloat(level)
        
        // character set up
        let x = collectionView.frame.origin.x
        let y = collectionView.frame.origin.y 
        charater.frame = CGRect(x: x + (width*1.5)/5, y: y + (width*1.5)/5, width: width/5 * 2, height: width/5 * 2)
        charater.backgroundColor = secondary
        charater.layer.cornerRadius = width/5
        
        view.insertSubview(charater, belowSubview: interactionView)
        collectionView.reloadData()
    }
    
    // MARK: record the first touch location
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location = (touches.first?.location(in: interactionView))! as CGPoint
        prevTouch = location
    }
    
    // MARK: check where the next the finger moved
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location = (touches.first?.location(in: interactionView))! as CGPoint
        
        // finger moved to the left
        if (prevTouch.x - location.x) > width {
            prevTouch = location
            swipe_left_action()
        }
        
        // finger moved to the right
        if (prevTouch.x - location.x) < -width {
            prevTouch = location
            swipe_right_action()
        }
        
        // finger moved to the up
        if (prevTouch.y - location.y) > width {
            prevTouch = location
            swipe_up_action()
        }
        
        // finger moved to the down
        if (prevTouch.y - location.y) < -width {
            prevTouch = location
            swipe_down_action()
        }
    }
    
    // MARK: randomise
    func randomise() {
        
        for _ in 0...(Int((level*level)/2)-1) {
            let x = Int(arc4random_uniform(5)+1)
            // randomise 1 number and make the other one adds up to 10
            storage.append(x)
            storage.append(10-x)
        }
        
        if level%2 != 0 {
            // even it is an uneven grid add a 5 at the end
            storage.append(5)
        }
        
        for _ in 0..<storage.count {
            //randomise position
            let z = arc4random_uniform(UInt32(storage.count))
            counter.append(storage[Int(z)])
            storage.remove(at: Int(z))
        }
        
        collectionView.reloadData()
    }
    
    // MARK: Method for when game has started
    func start() {
        started = true
        prompt.isHidden = true
        scoreCounter.text = String(deducted)
    }
    
    // MARK: Method when screen is swiped
    func swipeMethods() {
        // deduct 1 point from the next position
        let pos = currPos[1] * level + currPos[0]
        counter[pos] -= 1
        deducted += 1
        scoreCounter.text = String(deducted)
        collectionView.reloadData()
        
        var x = [Int]()
        for _ in 0..<level*level {
            x.append(0)
        }
        
        // check if board is complete
        if counter == x {
            counter = []
            randomise()
        } else {
            check()
        }
    }
    
    // MARK: check if player is trapped
    func check() {
        var left = false
        var right = false
        var top = false
        var down = false
        
        if currPos[0] == 0 { left = true } else { if counter[currPos[1]*level + currPos[0] - 1] == 0 { left = true } }
        if currPos[0] == level - 1 { right = true } else { if counter[currPos[1]*level + currPos[0] + 1] == 0 { right = true } }
        if currPos[1] == 0 { top = true } else { if counter[(currPos[1]-1)*level + currPos[0]] == 0 { top = true } }
        if currPos[1] == level - 1 { down = true } else { if counter[(currPos[1]+1)*level + currPos[0]] == 0 { down = true } }
        
        if left && right && top && down {
            endButton.isHidden = false
        }
        
    }
    
    func swipe_up_action() {
        if !started { start() }
        
        if currPos[1] != 0 {
            if checkNext(pos: [currPos[0], currPos[1] - 1]) != currPos {
                currPos[1] -= 1
                UIView.animate(withDuration: animTime, delay: 0, usingSpringWithDamping: animSpring, initialSpringVelocity: animSpring, options: [], animations: {
                    self.charater.center.y -= self.width
                }, completion: nil)
                swipeMethods()
            }
        }
    }
    
    func swipe_down_action() {
        if !started { start() }
        
        if currPos[1] != level - 1 {
            if checkNext(pos: [currPos[0], currPos[1] + 1]) != currPos {
                currPos[1] += 1
                UIView.animate(withDuration: animTime, delay: 0, usingSpringWithDamping: animSpring, initialSpringVelocity: animSpring, options: [], animations: {
                    self.charater.center.y += self.width
                }, completion: nil)
                swipeMethods()
            }
        }
    }
    
    func swipe_left_action() {
        if !started { start() }
        
        if currPos[0] != 0 {
            if checkNext(pos: [currPos[0] - 1, currPos[1]]) != currPos {
                currPos[0] -= 1
                UIView.animate(withDuration: animTime, delay: 0, usingSpringWithDamping: animSpring, initialSpringVelocity: animSpring, options: [], animations: {
                    self.charater.center.x -= self.width
                }, completion: nil)
                swipeMethods()
            }
        }
    }
    
    func swipe_right_action() {
        if !started { start() }
        
        if currPos[0] != level - 1 {
            if checkNext(pos: [currPos[0] + 1, currPos[1]]) != currPos {
                currPos[0] += 1
                UIView.animate(withDuration: animTime, delay: 0, usingSpringWithDamping: animSpring, initialSpringVelocity: animSpring, options: [], animations: {
                    self.charater.center.x += self.width
                }, completion: nil)
                swipeMethods()
            }
        }
    }
    
    func checkNext(pos: [Int]) -> [Int] {
        
        if counter[pos[1]*level + pos[0]] == 0 {
            return currPos
        }
        
        return pos
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return level*level
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! gridCell
        
        var sec = UIColor()
        
        sec = secondary
        
        if counter[indexPath.row] < 6 { sec = tertiary }
        if counter[indexPath.row] < 4 { sec = quaternary }
        cell.counterLabel.text = "\(counter[indexPath.row])"
        if counter[indexPath.row] == 0 { cell.counterLabel.text = "" }
        
        cell.imageView.backgroundColor = primary
        cell.counterLabel.textColor = sec
        
//        if currPos[1]*level + currPos[0] == indexPath.row {
//            UIView.animate(withDuration: 0.15, animations: {
//                cell.counterLabel.transform = CGAffineTransform(scaleX: 4/5, y: 4/5)
//                cell.counterLabel.center = CGPoint(x: 1/5 * self.width, y: 4/5 * self.width)
//            })
//            UIView.animate(withDuration: 0.15, animations: {
//                cell.counterLabel.transform = CGAffineTransform(scaleX: 4/5, y: 4/5)
//                cell.counterLabel.center = CGPoint(x: 1/5 * self.width, y: 4/5 * self.width)
//            }, completion: { (Bool) in
//                cell.counterLabel.transform = CGAffineTransform(scaleX: 4/5, y: 4/5)
//                cell.counterLabel.center = CGPoint(x: 1/5 * self.width, y: 4/5 * self.width)
//            })
//        } else {
//            cell.counterLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
//            cell.counterLabel.center = CGPoint(x: 1/2 * width, y: 1/2 * width)
//        }
        
        return cell
    }
    
    func reset() {
        started = false
        deducted = 0
        counter = []
        randomise()
        currPos = [0,0]
        
        let x = collectionView.frame.origin.x
        let y = collectionView.frame.origin.y
        charater.frame = CGRect(x: x + (width*1.5)/5, y: y + (width*1.5)/5, width: width/5 * 2, height: width/5 * 2)
        collectionView.reloadData()
    }
    
    @IBAction func endGame(_ sender: Any) {
        if deducted > UserDefaults.standard.integer(forKey: "highscore") {
            UserDefaults.standard.set(deducted, forKey: "highscore")
        }
        self.highScore.text = String(UserDefaults.standard.integer(forKey: "highscore"))
        self.endButton.isHidden = true
        self.prompt.isHidden = false
        self.deducted = 0
        self.reset()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}
