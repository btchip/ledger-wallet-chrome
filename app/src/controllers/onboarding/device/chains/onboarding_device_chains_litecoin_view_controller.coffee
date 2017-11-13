class @OnboardingDeviceChainsLitecoinViewController extends @OnboardingViewController

  view:
    chainSelected: ".choice"
    remember: "#remember"
    advanced: "#advanced"
    openHelpCenter: "#help"
    recoverTool: "#recover"
    link: '#link'

  networks: []

  initialize: ->
    super
    @networks = JSON.parse @params.networks
    l @networks

  onAfterRender: ->
    super
    @view.chainSelected.on "click", @onChainSelected
    @view.advanced.change(@toggleAdvanced.bind(this))
    @toggleAdvanced()

  toggleAdvanced: () ->
    if @view.advanced.is(":checked")
      @view.openHelpCenter.hide()
      @view.recoverTool.show()
    else
      @view.openHelpCenter.show()
      @view.recoverTool.hide()

  bitcoinCashSelected: (e) ->
    dialog = new OnboardingDeviceChainsMessageDialogViewController()
    dialog.once 'click:split', =>
      @chainChoosen(@networks[3])
    dialog.once 'click:un_split', =>
      @chainChoosen(@networks[2])
    dialog.show()

  chooseSegwit: (e) ->
    dialog = new OnboardingDeviceChainsChoiceDialogViewController(title: t("onboarding.device.chains.segwit_title"), text: t('onboarding.device.chains.segwit_message'), firstChoice: t('onboarding.device.chains.segwit_deactivate'), secondChoice: t('onboarding.device.chains.segwit_activate'))
    dialog.once 'click:first', =>
      @chainChoosen(@networks[e.target.attributes.value.value])
    dialog.once 'click:second', =>
      @chainChoosen(@networks[e.target.attributes.value.value+1])
    dialog.show()

  recoverTool: (e) ->
    dialog = new OnboardingDeviceChainsRecoverDialogViewController()
    dialog.once 'click:recover', =>
      @chainChoosen(ledger.bitcoin.Networks.bitcoin_recover)
    dialog.show()

  incompatible: () ->
    dialog = new CommonDialogsMessageDialogViewController(kind: "error", title: t("onboarding.device.chains.bad_device_title"), subtitle: t('onboarding.device.chains.bad_device_message'))
    dialog.show()

  onChainSelected: (e) ->
    @chainChoosen(@networks[e.target.attributes.value.value])

  chainChoosen: (e) ->
    ledger.app.dongle.getPublicAddress "44'/#{@networks[0].bip44_coin_type}'/0'/0/0", (addr) =>
      address = ledger.crypto.SHA256.hashString addr.bitcoinAddress.toString(ASCII)
      tmp = {}
      if @view.remember.is(":checked")
        tmp[address]= e
        ledger.storage.global.chainSelector.set tmp, =>
          ledger.storage.global.chainSelector.get address, (result) =>
            ledger.app.onChainChosen(e)
      else
        tmp[address]= 0
        ledger.storage.global.chainSelector.set tmp, =>
          ledger.storage.global.chainSelector.get address, (result) =>
            ledger.app.onChainChosen(e)


  openSupport: ->
    window.open t 'application.support_url'

  onDetach: ->
    super

  openLink: ->
    open("https://bitcoincore.org/en/2016/01/26/segwit-benefits/")
