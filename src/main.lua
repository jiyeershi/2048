
cc.FileUtils:getInstance():setPopupNotify(false)
cc.FileUtils:getInstance():addSearchPath("src/")
cc.FileUtils:getInstance():addSearchPath("res/")


print (package.path)
CC_USE_FRAMEWORK = true
-- require "config"
require "cocos.init"
require "GameConfig"

local TestScene = require "GameScene"

local function main()
    -- require("app.MyApp"):create():run()
    cc.FileUtils:getInstance():addSearchPath("res/")
	-- cc.Director:getInstance():setContentScaleFactor(640 / 320)

	-- display.loadSpriteFrames("image/player.plist", "image/player.pvr.ccz")

	-- -- display.addSpriteFrames("image/player.plist", "image/player.pvr.ccz")
	-- audio.preloadMusic("sound/background.mp3") 
	-- audio.preloadSound("sound/button.wav")
	-- audio.preloadSound("sound/ground.mp3")
	-- audio.preloadSound("sound/heart.mp3")
	-- audio.preloadSound("sound/hit.mp3")

    local testScene = TestScene:create()
    cc.Director:getInstance():runWithScene(testScene)
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
