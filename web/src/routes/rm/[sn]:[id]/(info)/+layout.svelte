<script lang="ts">
  import { get_user } from '$lib/stores'
  const _user = get_user()

  import SIcon from '$gui/atoms/SIcon.svelte'
  import UpstemFull from '$gui/parts/upstem/UpstemFull.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ ustem, sroot } = data)
</script>

<UpstemFull {ustem} binfo={data.binfo || null} />

{#if $_user.vu_id >= 3}
  <nav class="admin">
    <a href="{sroot}/ul" class="m-btn _fill _primary">
      <SIcon name="upload" />
      <span class="-txt">Thêm nội dung</span>
    </a>
    <a href="{sroot}/su" class="m-btn">
      <SIcon name="tools" />
      <span class="-txt">Trang quản lý</span>
    </a>
    <a href="/up/+proj?id={ustem.id}" class="m-btn _fill _warning">
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
