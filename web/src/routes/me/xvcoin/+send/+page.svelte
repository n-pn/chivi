<script lang="ts">
  import { get_user } from '$lib/stores'
  const _user = get_user()

  import type { PageData } from './$types'
  export let data: PageData

  let xform = data.xform || { target: '', reason: '', amount: 10 }
  import SendVcoin from '$gui/shared/usercp/Setting/SendVcoin.svelte'
</script>

<article class="article island">
  <h2>Gửi tặng Vcoin</h2>

  <SendVcoin {_user} {xform} />
</article>

<style lang="scss">
  .article {
    margin-top: 0.75rem;
  }

  h2 {
    text-align: center;
  }
</style>
