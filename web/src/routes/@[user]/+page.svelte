<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'
  import GdreplList from '$gui/parts/dboard/GdreplList.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ gdroot, rplist, viuser } = data)
</script>

<h2 class="head">
  Trang cá nhân của <cv-user data-privi={viuser.privi}
    >{viuser.uname}
    <SIcon name="privi-{viuser.privi}" iset="icons" />
  </cv-user>
</h2>

<p class="u-fg-tert"><em>(Trang đang hoàn thiện)</em></p>
<p>Bạn có thể thêm lời nhắn cho {viuser.uname} tại đây.</p>

<section>
  <h3>Lời nhắn <span class="m-badge">{rplist.repls.length}</span>:</h3>
  <GdreplList
    {rplist}
    gdroot="id:{gdroot.id}"
    touser={gdroot.user_id}
    fluid={true}
    _kind="lời nhắn" />
</section>

<style lang="scss">
  .head {
    margin-top: 1rem;
  }

  h3 {
    padding: 0.5rem 0;
  }
</style>
