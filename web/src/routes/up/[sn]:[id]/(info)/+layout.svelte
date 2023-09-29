<script lang="ts">
  import { get_user } from '$lib/stores'
  const _user = get_user()

  import SIcon from '$gui/atoms/SIcon.svelte'
  import UpstemFull from '$gui/parts/upstem/UpstemFull.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ ustem, sroot } = data)

  $: is_owner = $_user.vu_id == ustem.viuser_id
</script>

<UpstemFull {ustem} binfo={data.binfo || null} />

{#if is_owner || $_user.vu_id > 3}
  <nav class="admin">
    <a href="{sroot}/ul" class="m-btn _fill _primary">
      <SIcon name="upload" />
      <span class="-txt">Thêm text gốc</span>
    </a>
    <a href="{sroot}/su" class="m-btn _primary">
      <SIcon name="tools" />
      <span class="-txt">Sửa thiết đặt</span>
    </a>
    <a href="/up/+proj?id={ustem.id}" class="m-btn _warning">
      <SIcon name="pencil" />
      <span class="-txt">Sửa thông tin</span>
    </a>
  </nav>
{/if}

<slot />

<style lang="scss">
  .admin {
    @include flex-ca($gap: 0.5rem);
    margin-bottom: 1rem;
  }
</style>
